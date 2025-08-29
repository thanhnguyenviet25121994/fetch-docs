#### How to: 
# put the mp3 file to telegram noti desk top. 


import sounddevice as sd
import numpy as np
from scipy.io import wavfile
from pydub import AudioSegment
from pydub.playback import play
import time

import sounddevice as sd


def audio_callback(indata, frames, time_info, status):
    if status:
        print("Status:", status)
    # Flatten to mono
    audio = indata.mean(axis=1)
    audio = audio / np.max(np.abs(audio))

    # Correlation to detect similarity
    corr = np.correlate(audio, ref_data, mode='valid')
    similarity = np.max(np.abs(corr))

    print("Similarity:", similarity)

    if similarity > 178:  # You may need to tune this threshold
        print("Detected matching sound! Playing music...")
        # time.sleep(5)
        # firt run
        play(music)
        # time.sleep(900)

        #second run
        play(music)
        # time.sleep(900)

        # #third run
        # play(music)
        # # time.sleep(900)

        

while True:
    try: 
        # Find the correct input device index
        device_info = sd.query_devices(kind='input')
        print("Default input device:", device_info['name'])
        print("Max input channels:", device_info['max_input_channels'])
        # print(sd.query_devices())

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
        CHUNK_DURATION = 2  # seconds
        SAMPLE_RATE = 44100


        # Start streaming from system audio (you may need to configure device)
        print("Listening to system audio...")
        with sd.InputStream(callback=audio_callback,
                            channels=channels,
                            samplerate=SAMPLE_RATE,
                            blocksize=int(SAMPLE_RATE * CHUNK_DURATION)):
            while True:
                time.sleep(0.001)
    except:
        print(f"stop current play, go to next loop!")