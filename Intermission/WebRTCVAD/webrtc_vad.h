/*
 * WebRTC Voice Activity Detector (VAD)
 * Header file for the VAD interface
 */

#ifndef WEBRTC_VAD_H_
#define WEBRTC_VAD_H_

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct WebRtcVadInst VadInst;

/*
 * Creates an instance of the VAD.
 * Returns NULL on error.
 */
VadInst* webrtc_vad_create(void);

/*
 * Frees the VAD instance.
 */
void webrtc_vad_free(VadInst* handle);

/*
 * Initializes the VAD instance.
 * Returns 0 on success, -1 on error.
 */
int webrtc_vad_init(VadInst* handle);

/*
 * Sets the VAD operating mode.
 * mode: Aggressiveness mode (0-3)
 *   0: Quality mode
 *   1: Low bitrate mode
 *   2: Aggressive mode
 *   3: Very aggressive mode
 * Returns 0 on success, -1 on error.
 */
int webrtc_vad_set_mode(VadInst* handle, int mode);

/*
 * Processes a frame and detects voice activity.
 *
 * sample_rate_hz: Sampling frequency in Hz (8000, 16000, 32000, or 48000)
 * audio_frame: Audio frame buffer (16-bit PCM)
 * frame_length: Number of samples in the frame
 *               Must be 80, 160, or 240 for 8kHz
 *               Must be 160, 320, or 480 for 16kHz
 *               Must be 320, 640, or 960 for 32kHz
 *               Must be 480, 960, or 1440 for 48kHz
 *
 * Returns:
 *   1: Voice activity detected
 *   0: No voice activity
 *  -1: Error
 */
int webrtc_vad_process(VadInst* handle,
                       int sample_rate_hz,
                       const int16_t* audio_frame,
                       size_t frame_length);

#ifdef __cplusplus
}
#endif

#endif  // WEBRTC_VAD_H_
