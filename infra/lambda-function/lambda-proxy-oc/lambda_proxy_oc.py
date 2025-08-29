import psycopg2
import os
import json
from cuid2 import cuid_wrapper
from flask import Flask, request, jsonify
from mangum import Mangum 
# Initialize Flask app
app = Flask(__name__)

# Generate unique IDs
cuid_generator = cuid_wrapper()

def get_db_connection():
    """Establish a connection to the PostgreSQL database."""
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "service_entity"),
        port="5432",
        user=os.getenv("DB_USER", "service_entity"),
        password=os.getenv("DB_PASSWORD", "dev")
    )

def insert_brand_if_not_exists(code):
    """Insert brand if it doesn't exist and return brand_id."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if brand exists
        cursor.execute("SELECT id FROM public.brands WHERE code = %s", (code,))
        existing_brand = cursor.fetchone()

        if existing_brand:
            return existing_brand[0]  # Return existing brand ID

        # Generate unique brand ID
        brand_id = cuid_generator()
        group_id = "e1vkyg83dbtejs34pncztasl"
        token = cuid_generator()

        # Insert new brand
        insert_query = """
        INSERT INTO public.brands 
        (code, group_id, name, description, website, endpoint, status, created, updated, id, token, flags, launcher_title)
        VALUES (%s, %s, %s, %s, %s, %s, 'ACTIVE', NOW(), NOW(), %s, %s, 0, 'Default Launcher')
        RETURNING id;
        """
        cursor.execute(insert_query, (code, group_id, code, code, 
                                      "https://operator-demo.dev.revenge-games.com", 
                                      "https://operator-demo.dev.revenge-games.com", 
                                      brand_id, token))

        new_brand_id = cursor.fetchone()[0]
        conn.commit()
        return new_brand_id

    except Exception as e:
        print(f"Database error: {e}")
        return None  

    finally:
        cursor.close()
        conn.close()

def get_game_id_by_code(game_code):
    """Fetch game ID using game_code."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT id FROM public.games WHERE code = %s", (game_code,))
        result = cursor.fetchone()

        return result[0] if result else None

    except Exception as e:
        print(f"Database error: {e}")
        return None

    finally:
        cursor.close()
        conn.close()

def insert_game_if_not_exists(brand_id, game_id, logic_url=""):
    """Insert or update game in available_games table."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if the game exists for this brand
        cursor.execute("SELECT id FROM public.available_games WHERE brand_id = %s AND game_id = %s", (brand_id, game_id))
        existing_game = cursor.fetchone()

        if existing_game:
            existing_game_id = existing_game[0]

            # Update logic_url if game exists
            update_query = """
            UPDATE public.available_games 
            SET logic_url = %s, updated = NOW()
            WHERE id = %s
            RETURNING id;
            """
            cursor.execute(update_query, (logic_url, existing_game_id))
            conn.commit()
            return existing_game_id

        # Generate new cuid for game ID
        game_entry_id = cuid_generator()

        # Insert new game record
        insert_query = """
        INSERT INTO public.available_games 
        (brand_id, game_id, created, updated, id, logic_url, url, status, feature_set_id, tags)
        VALUES (%s, %s, NOW(), NOW(), %s, %s, '', 'ACTIVE', '', '{}')
        RETURNING id;
        """
        cursor.execute(insert_query, (brand_id, game_id, game_entry_id, logic_url))

        new_game_id = cursor.fetchone()[0]
        conn.commit()
        return new_game_id  

    except Exception as e:
        print(f"Database error: {e}")
        return None  

    finally:
        cursor.close()
        conn.close()

@app.route("/insert_game", methods=["POST"])
def insert_game():
    """API endpoint to insert or update a game."""
    try:
        data = request.get_json()

        oc = data.get("oc")  # Operator Code (Brand Code)
        game_code = data.get("game_code")
        logic_url = data.get("logic_url", "")

        if not oc or not game_code:
            return jsonify({"error": "oc and game_code are required"}), 400

        # Insert brand if not exists
        brand_id = insert_brand_if_not_exists(oc)
        if not brand_id:
            return jsonify({"error": "Failed to insert or retrieve brand"}), 500

        # Get game ID
        game_id = get_game_id_by_code(game_code)
        if not game_id:
            return jsonify({"error": f"Game not found for code: {game_code}"}), 404

        # Insert or update game entry
        game_entry_id = insert_game_if_not_exists(brand_id, game_id, logic_url=logic_url)

        return jsonify({
            "message": "Successfully inserted/updated game",
            "brand_id": brand_id,
            "game_entry_id": game_entry_id
        })

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": "Internal Server Error"}), 500

# Wrap Flask app for AWS Lambda
handler = Mangum(app)
