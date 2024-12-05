/*
 Copyright (c) 2024 Bruce A Henderson
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/
#define PL_MPEG_IMPLEMENTATION
#include "pl_mpeg.h"

#include "brl.mod/blitz.mod/blitz.h"

// #define PLM_BUFFER_MODE_STREAM 5

extern void video_mpeg1_TMpeg1__VideoCallback(BBObject * obj, plm_frame_t * buffer);
extern void video_mpeg1_TMpeg1__AudioCallback(BBObject * obj, plm_samples_t * samples);
extern void video_mpeg1_TMpeg1__LoadCallback(BBObject * obj, plm_buffer_t * buffer);
extern void video_mpeg1_TMpeg1__SeekCallback(BBObject * obj, plm_buffer_t * buffer, size_t offset);

void bmx_mpeg1_load_callback(plm_buffer_t * buffer, void * data) {
    video_mpeg1_TMpeg1__LoadCallback((BBObject*)data, buffer);
}

void bmx_mpeg1_seek_callback(plm_buffer_t * buffer, size_t offset, void * data) {
    video_mpeg1_TMpeg1__SeekCallback((BBObject*)data, buffer, offset);
}

void bmx_mpeg1_video_callback(plm_t *player, plm_frame_t *frame, void *user) {
    video_mpeg1_TMpeg1__VideoCallback((BBObject*)user, frame);   
}

void bmx_mpeg1_audio_callback(plm_t *player, plm_samples_t *samples, void *user) {
    video_mpeg1_TMpeg1__AudioCallback((BBObject*)user, samples);
}

plm_buffer_t * bmx_mpeg1_create_buffer(BBObject * obj, size_t size) {
    plm_buffer_t * buffer = plm_buffer_create_with_capacity(PLM_BUFFER_DEFAULT_SIZE);
	buffer->close_when_done = 0;
	buffer->mode = PLM_BUFFER_MODE_STREAM;
	buffer->discard_read_bytes = TRUE;
	buffer->total_size = size;
	plm_buffer_set_load_callback(buffer, bmx_mpeg1_load_callback, obj);
    plm_buffer_set_seek_callback(buffer, bmx_mpeg1_seek_callback, obj);
    return buffer;
};

plm_t * bmx_mpeg1_create(BBObject * obj, plm_buffer_t *buffer, int destroy_when_done) {
    plm_t * plm = plm_create_with_buffer(buffer, destroy_when_done);
    plm_set_video_decode_callback(plm, bmx_mpeg1_video_callback, obj);
	plm_set_audio_decode_callback(plm, bmx_mpeg1_audio_callback, obj);
    return plm;
}

void bmx_mpeg1_destroy(plm_t * plm) {
    plm_destroy(plm);
}

void bmx_plm_frame_to_rgba(plm_frame_t *frame, uint8_t *dest, int stride, int fillAlpha, int capacity) {
    if (fillAlpha) {
        memset(dest, 255, capacity);
    }
    plm_frame_to_rgba(frame, dest, stride);
}
