#### How to: 
# put the mp3 file to telegram noti desk top. 


import sounddevice as sd
import numpy as np
from scipy.io import wavfile
from pydub import AudioSegment
from pydub.playback import play
import time

import sounddevice as sd


def normalized_cross_correlation(a, b):
    a = (a - np.mean(a)) / (np.std(a) * len(a))
    b = (b - np.mean(b)) / np.std(b)
    return np.correlate(a, b, mode='valid')

def audio_callback(indata, frames, time_info, status):
    if status:
        print("Status:", status)

    audio = indata.mean(axis=1)
    audio = audio / np.max(np.abs(audio))

    corr = normalized_cross_correlation(audio, ref_data)
    similarity = np.max(np.abs(corr))

    print("Similarity:", similarity)

    if similarity > 0.35:  # Example threshold for NCC
        print("Detected matching sound! Playing music...")
        time.sleep(5)
        #first time playing
        play(music)

        #second time playing
        play(music)

        

while True:
    try: 
        # Find the correct input device index
        device_info = sd.query_devices(kind='input')
        print("Default input device:", device_info['name'])
        print("Max input channels:", device_info['max_input_channels'])

        # time.sleep(300)
        # Set channels to what the device supports (typically 1 or 2)
        channels = min(2, device_info['max_input_channels'])

        # time.sleep(300)

        # input wave
        ref_sample_rate, ref_data = wavfile.read('input.wav')

        # Convert to mono if stereo
        if len(ref_data.shape) > 1:
            ref_data = ref_data.mean(axis=1)

        # Normalize and convert to float32
        ref_data = ref_data.astype(np.float32)
        ref_data = ref_data / np.max(np.abs(ref_data))

        # Load music to play when detected
        # music = AudioSegment.from_file("output.wav")
        music = AudioSegment.from_file("strong-style-energy-spring-sport-rock-191690.mp3")


        # Settings for live audio capture
        CHUNK_DURATION = 1  # seconds
        SAMPLE_RATE = 44100


        # Start streaming from system audio (you may need to configure device)
        print("Listening to system audio...")
        with sd.InputStream(callback=audio_callback,
                            channels=channels,
                            samplerate=SAMPLE_RATE,
                            blocksize=int(SAMPLE_RATE * CHUNK_DURATION)):
            while True:
                time.sleep(0.1)
    except:
        print(f"stop current play, go to next loop!")