' Copyright (c) 2024 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Import BRL.Stream
Import BRL.Pixmap

Import "mpeg/*.h"

Import "glue.c"

Extern
	Function plm_create_with_filename:Byte Ptr()

	Function bmx_mpeg1_create_buffer:SMpeg1Buffer Ptr(obj:Object, size:Size_T)
	Function bmx_mpeg1_create:Byte Ptr(obj:Object, buffer:SMpeg1Buffer Ptr, destroy_when_done:Int)
	Function bmx_mpeg1_destroy(handle:Byte Ptr)
	Function plm_get_width:Int(handle:Byte Ptr)
	Function plm_get_height:Int(handle:Byte Ptr)
	Function plm_set_video_enabled(handle:Byte Ptr, enabled:Int)
	Function plm_get_video_enabled:Int(handle:Byte Ptr)
	Function plm_set_audio_enabled(handle:Byte Ptr, enabled:Int)
	Function plm_get_audio_enabled:Int(handle:Byte Ptr)
	Function plm_get_num_audio_streams:Int(handle:Byte Ptr)
	Function plm_get_samplerate:Int(handle:Byte Ptr)
	Function plm_get_time:Double(handle:Byte Ptr)
	Function plm_get_duration:Double(handle:Byte Ptr)
	Function plm_decode(handle:Byte Ptr, seconds:Double)
	Function plm_frame_to_bgra(frame:SMpeg1Frame Ptr, dest:Byte Ptr, stride:Int)
	Function plm_frame_to_rgba(frame:SMpeg1Frame Ptr, dest:Byte Ptr, stride:Int)
	Function plm_frame_to_rgb(frame:SMpeg1Frame Ptr, dest:Byte Ptr, stride:Int)
	Function plm_frame_to_argb(frame:SMpeg1Frame Ptr, dest:Byte Ptr, stride:Int)
	Function plm_frame_to_abgr(frame:SMpeg1Frame Ptr, dest:Byte Ptr, stride:Int)
	Function plm_buffer_write:Size_T(buffer:Byte Ptr, buf:Byte Ptr, bytesRead:Size_T)
	Function plm_get_framerate:Double(handle:Byte Ptr)
	Function plm_has_ended:Int(handle:Byte Ptr)
	Function plm_set_audio_lead_time(handle:Byte Ptr, leadTime:Double)
	Function plm_get_loop:Int(handle:Byte Ptr)
	Function plm_set_loop(handle:Byte Ptr, loop:Int)
	Function plm_buffer_discard_read_bytes(buffer:SMpeg1Buffer Ptr)

	Function bmx_plm_frame_to_rgba(me:SMpeg1Frame Ptr, dest:Byte Ptr, stride:Int, fillAlpha:Int, capacity:Int)
End Extern

Struct SMpeg1Plane
	Field width:UInt
	Field height:UInt
	Field data:Byte Ptr
End Struct

Struct SMpeg1Frame
	Field time:Double
	Field width:UInt
	Field height:UInt
	Field y:SMpeg1Plane
	Field cr:SMpeg1Plane
	Field cb:SMpeg1Plane
End Struct

Struct SMpeg1Samples
	Field time:Double
	Field count:UInt
	Field StaticArray interleaved:Float[1152 * 2]
End Struct

Struct SMpeg1Buffer
	Field bitIndex:Size_T
	Field capacity:Size_T
	Field length:Size_T
	Field totalSize:Size_T
	Field discardReadBytes:Int
	Field hasEnded:Int
	Field freeWhenDone:Int
	Field closeWhenDone:Int
	Field fh:Byte Ptr
	Field loadCallback:Byte Ptr
	Field loadCallbackUserData:Byte Ptr
	Field seekCallback:Byte Ptr
	Field seekCallbackUserData:Byte Ptr
	Field bytes:Byte Ptr
	Field bufferMode:Int
End Struct
