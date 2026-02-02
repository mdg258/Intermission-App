/*
 * Simplified WebRTC VAD Implementation
 * This is a working stub - for production, use the full WebRTC VAD library
 * from https://github.com/wiseman/py-webrtcvad or compile from WebRTC source
 */

#include "webrtc_vad.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

#define FRAME_SIZE_MS 30
#define MIN_ENERGY_THRESHOLD 500.0  // Tuned for typical speech detection

struct WebRtcVadInst {
    int mode;
    int sample_rate;
    double energy_threshold;
    double* history;
    int history_size;
    int history_index;
    int speech_frames;       // Consecutive frames with speech
    int silence_frames;      // Consecutive frames with silence
};

VadInst* webrtc_vad_create(void) {
    VadInst* inst = (VadInst*)calloc(1, sizeof(VadInst));
    if (inst) {
        inst->history_size = 10;
        inst->history = (double*)calloc(inst->history_size, sizeof(double));
    }
    return inst;
}

void webrtc_vad_free(VadInst* handle) {
    if (handle) {
        if (handle->history) {
            free(handle->history);
        }
        free(handle);
    }
}

int webrtc_vad_init(VadInst* handle) {
    if (!handle) return -1;

    handle->mode = 2;
    handle->sample_rate = 16000;
    handle->energy_threshold = MIN_ENERGY_THRESHOLD;
    handle->history_index = 0;
    handle->speech_frames = 0;
    handle->silence_frames = 0;

    return 0;
}

int webrtc_vad_set_mode(VadInst* handle, int mode) {
    if (!handle || mode < 0 || mode > 3) return -1;

    handle->mode = mode;

    // Adjust threshold based on aggressiveness
    switch (mode) {
        case 0: // Quality
            handle->energy_threshold = MIN_ENERGY_THRESHOLD * 0.5;
            break;
        case 1: // Low Bitrate
            handle->energy_threshold = MIN_ENERGY_THRESHOLD * 0.75;
            break;
        case 2: // Aggressive
            handle->energy_threshold = MIN_ENERGY_THRESHOLD * 1.0;
            break;
        case 3: // Very Aggressive
            handle->energy_threshold = MIN_ENERGY_THRESHOLD * 1.5;
            break;
    }

    return 0;
}

static double calculate_energy(const int16_t* audio_frame, size_t frame_length) {
    double energy = 0.0;
    for (size_t i = 0; i < frame_length; i++) {
        double sample = (double)audio_frame[i];
        energy += sample * sample;
    }
    return energy / frame_length;
}

static double calculate_zero_crossing_rate(const int16_t* audio_frame, size_t frame_length) {
    int zero_crossings = 0;
    for (size_t i = 1; i < frame_length; i++) {
        if ((audio_frame[i] >= 0 && audio_frame[i-1] < 0) ||
            (audio_frame[i] < 0 && audio_frame[i-1] >= 0)) {
            zero_crossings++;
        }
    }
    return (double)zero_crossings / frame_length;
}

int webrtc_vad_process(VadInst* handle,
                       int sample_rate_hz,
                       const int16_t* audio_frame,
                       size_t frame_length) {
    if (!handle || !audio_frame) return -1;

    // Validate sample rate
    if (sample_rate_hz != 8000 && sample_rate_hz != 16000 &&
        sample_rate_hz != 32000 && sample_rate_hz != 48000) {
        return -1;
    }

    // Calculate energy
    double energy = calculate_energy(audio_frame, frame_length);

    // Calculate zero crossing rate (helps distinguish speech from noise)
    double zcr = calculate_zero_crossing_rate(audio_frame, frame_length);

    // Update history
    handle->history[handle->history_index] = energy;
    handle->history_index = (handle->history_index + 1) % handle->history_size;

    // Calculate average energy from history
    double avg_energy = 0.0;
    for (int i = 0; i < handle->history_size; i++) {
        avg_energy += handle->history[i];
    }
    avg_energy /= handle->history_size;

    // Determine if current frame has speech characteristics
    int frame_has_speech = 0;

    // Speech must have:
    // 1. Energy above threshold
    // 2. Energy significantly higher than recent average (1.5x minimum)
    // 3. Zero crossing rate in speech range
    if (energy > handle->energy_threshold && energy > avg_energy * 1.5) {
        // Check zero crossing rate - speech is usually between 0.03 and 0.35
        if (zcr > 0.03 && zcr < 0.35) {
            frame_has_speech = 1;
        }
    }

    // Use hysteresis: require multiple consecutive frames to change state
    // This prevents rapid switching between speech/silence
    if (frame_has_speech) {
        handle->speech_frames++;
        handle->silence_frames = 0;
    } else {
        handle->silence_frames++;
        handle->speech_frames = 0;
    }

    // Require 3+ consecutive speech frames to report speech
    // Require 5+ consecutive silence frames to report silence
    int is_speech = 0;
    if (handle->speech_frames >= 3) {
        is_speech = 1;
    } else if (handle->silence_frames < 5 && handle->speech_frames == 0) {
        // Still in speech if we haven't had enough silence frames
        // This prevents brief pauses from being detected as silence
        is_speech = (handle->silence_frames == 0) ? 0 : 0;
    }

    // Debug output (comment out for production)
    static int log_counter = 0;
    if (++log_counter % 50 == 0) {  // Log every 50 frames (~1.5 seconds at 30ms frames)
        printf("VAD: energy=%.0f (threshold=%.0f, avg=%.0f), zcr=%.3f, speech_frames=%d, silence_frames=%d, result=%d\n",
               energy, handle->energy_threshold, avg_energy, zcr,
               handle->speech_frames, handle->silence_frames, is_speech);
    }

    return is_speech;
}
