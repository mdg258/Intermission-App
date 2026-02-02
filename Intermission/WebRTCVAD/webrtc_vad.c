/*
 * Simplified WebRTC VAD Implementation
 * This is a working stub - for production, use the full WebRTC VAD library
 * from https://github.com/wiseman/py-webrtcvad or compile from WebRTC source
 */

#include "webrtc_vad.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define FRAME_SIZE_MS 30
#define MIN_ENERGY_THRESHOLD 100.0

struct WebRtcVadInst {
    int mode;
    int sample_rate;
    double energy_threshold;
    double* history;
    int history_size;
    int history_index;
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

    // Speech detection logic
    // Speech typically has:
    // - Higher energy than background noise
    // - Moderate zero crossing rate (not too high like white noise)
    int is_speech = 0;

    if (energy > handle->energy_threshold) {
        // Check zero crossing rate - speech is usually between 0.05 and 0.3
        if (zcr > 0.02 && zcr < 0.5) {
            // Also check if current energy is significantly higher than recent average
            if (energy > avg_energy * 0.7 || energy > handle->energy_threshold * 1.2) {
                is_speech = 1;
            }
        }
    }

    return is_speech;
}
