import psycopg2
from psycopg2 import OperationalError

def connect_to_postgres(host, dbname, user, password, port):
    try:
        connection = psycopg2.connect(
            host=host,
            dbname=dbname,
            user=user,
            password=password,
            port=port
        )
        print("Connection successful")
        return connection
    except Exception as e:
        print(f"An error occured: {e}")
        return None


def query_postgresdb(conn, query, params=None, fetch=False):
    with conn.cursor() as cursor:
        cursor.execute(query, params)
        if fetch:
            result = cursor.fetchall()
            return result
        else:
            conn.commit()
