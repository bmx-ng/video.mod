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

Rem
bbdoc: Video/Mpeg1 playback.
End Rem
Module Video.Mpeg1

ModuleInfo "Version: 1.00"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: pl_mpeg - 2019 Dominic Szablewski"
ModuleInfo "Copyright: Wrapper - 2024 Bruce A Henderson"

ModuleInfo "History: 1.00 Initial Release"

Import "common.bmx"

' Notes
'
' Changes made to pl_mpeg.h to support a PLM_BUFFER_MODE_STREAM mode.
'

Rem
bbdoc: An MPEG1 video player.
End Rem
Type TMpeg1

	Field mpgPtr:Byte Ptr

	Field mpegStream:TMpeg1Stream
	Field videoHandler:IVideoHandler
	Field pix:TPixmap

	Method New(mpegStream:TMpeg1Stream, videoHandler:IVideoHandler)
		mpgPtr = bmx_mpeg1_create(Self, mpegStream.buffer, True)

		Self.mpegStream = mpegStream
		Self.videoHandler = videoHandler

		pix = videoHandler.Pixmap(Width(), Height(), PF_RGB888)
	End Method

	Rem
	bbdoc: Loads a video from a file.
	End Rem
	Function Load:TMpeg1(filename:String, videoHandler:IVideoHandler)
		If videoHandler = Null Then
			Throw "videoHandler is required"
		End If

		Local stream:TStream = ReadStream(filename)
		If stream Then
			Return Load(stream, videoHandler)
		End If
	End Function

	Rem
	bbdoc: Loads a video from a stream.
	End Rem
	Function Load:TMpeg1(stream:TStream, videoHandler:IVideoHandler)
		If videoHandler = Null Then
			Throw "videoHandler is required"
		End If

		Local mpegStream:TMpeg1Stream = New TMpeg1Stream(stream)

		Local mpg:TMpeg1 = New TMpeg1(mpegStream, videoHandler)
		videoHandler.InitAudio(mpg)
		Return mpg
	End Function

	Method Delete()
		If mpgPtr Then
			bmx_mpeg1_destroy(mpgPtr)
			mpgPtr = Null
		End If
	End Method

	Rem
	bbdoc: Returns the width of the video, in pixels.
	End Rem
	Method Width:Int()
		Return plm_get_width(mpgPtr)
	End Method

	Rem
	bbdoc: Returns the height of the video, in pixels.
	End Rem
	Method Height:Int()
		Return plm_get_height(mpgPtr)
	End Method

	Rem
	bbdoc: Returns #Tue if video decoding is enabled.
	End Rem
	Method GetVideoEnabled:Int()
		Return plm_get_video_enabled(mpgPtr)
	End Method

	Rem
	bbdoc: Enables or disables video decoding.
	about: If video is disabled, the video decode callback will not be called.
	End Rem
	Method SetVideoEnabled(videoEnabled:Int)
		plm_set_video_enabled(mpgPtr, videoEnabled)
	End Method

	Rem
	bbdoc: Returns #True if audio decoding is enabled.
	End Rem
	Method GetAudioEnabled:Int()
		Return plm_get_audio_enabled(mpgPtr)
	End Method

	Rem
	bbdoc: Enables or disables audio decoding.
	about: If audio is disabled, the audio decode callback will not be called.
	End Rem
	Method SetAudioEnabled(audioEnabled:Int)
		plm_set_audio_enabled(mpgPtr, audioEnabled)
	End Method

	Rem
	bbdoc: Returns the current internal time of the video, in seconds.
	End Rem
	Method GetTime:Double()
		Return plm_get_time(mpgPtr)
	End Method

	Rem
	bbdoc: Advances the internal timer by @elapsedTime seconds and decode video/audio up to this time.
	about: This will call the video decode callback and audio decode callback any number
	of times. A frame-skip is not implemented, i.e. everything up to current time will be decoded.
	End Rem
	Method Decode(elapsedTime:Double)
		plm_decode(mpgPtr, elapsedTime)
	End Method

	Rem
	bbdoc: Returns the current framerate of the video.
	End Rem
	Method Framerate:Double()
		Return plm_get_framerate(mpgPtr)
	End Method

	Rem
	bbdoc: Returns the current samplerate of the video.
	End Rem
	Method Samplerate:Int()
		Return plm_get_samplerate(mpgPtr)
	End Method

	Rem
	bbdoc: Returns the duration of the video in seconds.
	End Rem
	Method Duration:Double()
		Return plm_get_duration(mpgPtr)
	End Method

	Rem
	bbdoc: Return #True if the video has ended.
	End Rem
	Method HasEnded:Int()
		Return plm_has_ended(mpgPtr)
	End Method

	Rem
	bbdoc: Sets the the audio lead time in seconds - the time in which audio samples are decoded in advance (or behind) the video decode time.
	about: Typically this should be set to the duration of the buffer of the audio API that you use for output.
	End Rem
	Method SetAudioLeadTime(leadTime:Double)
		plm_set_audio_lead_time(mpgPtr, leadTime)
	End Method

	Rem
	bbdoc: Returns whether looping is enabled.
	End Rem
	Method GetLoop:Int()
		Return plm_get_loop(mpgPtr)
	End Method

	Rem
	bbdoc: Sets the looping mode.
	about: If loop is set to #True, the video will loop when it reaches the end, otherwise it will stop.
	End Rem
	Method SetLoop(loop:Int)
		plm_set_loop(mpgPtr, loop)
	End Method

	Function _LoadCallback(stream:TMpeg1Stream, buffer:SMpeg1Buffer Ptr) { nomangle }
		stream.Read()
	End Function

	Function _SeekCallback(stream:TMpeg1Stream, buffer:SMpeg1Buffer Ptr, offset:Size_T) { nomangle }
		stream.Seek(offset)
	End Function

	Function _VideoCallback(mpg:TMpeg1, frame:SMpeg1Frame Ptr) { nomangle }
		If mpg.videoHandler Then
			If mpg.pix.format = PF_RGB888 Then
				plm_frame_to_rgb(frame, mpg.pix.pixels, frame.width * 3)
			Else If mpg.pix.format = PF_RGBA8888 Then
				bmx_plm_frame_to_rgba(frame, mpg.pix.pixels, frame.width * 4, True, mpg.pix.capacity)
			End If
			mpg.videoHandler.VideoCallback(mpg.pix)
		End If
	End Function

	Function _AudioCallback(mpg:TMpeg1, frame:SMpeg1Samples Ptr) { nomangle }
		If mpg.videoHandler Then
			mpg.videoHandler.AudioCallback(frame)
		End If
	End Function
End Type

Interface IVideoHandler
	Method VideoCallback(pix:TPixmap)
	Method AudioCallback(frame:SMpeg1Samples Ptr)
	Method Pixmap:TPixmap(width:Int, height:Int, format:Int)
	Method InitAudio(mpg:TMpeg1)
End Interface

Type TMpeg1Stream

	Field buffer:SMpeg1Buffer Ptr
	Field stream:TStream
	Field buf:Byte[4096]

	Method New(stream:TStream)
		buffer = bmx_mpeg1_create_buffer(Self, Size_T(stream.Size()))
		Self.stream = stream
	End Method

	Method Read()
		If buffer.discardReadBytes Then
			plm_buffer_discard_read_bytes(buffer)
		End If

		Local bytesAvailable:Size_T = buffer.capacity - buffer.length
		Local bytesRead:Size_T = stream.Read(buffer.bytes + buffer.length, bytesAvailable)
		buffer.length :+ bytesRead

		If bytesRead = 0 Then
			buffer.hasEnded = True
		End If
	End Method

	Method Seek(offset:Size_T)
		stream.Seek(offset)
		buffer.bitIndex = 0
		buffer.length = 0
	End Method
End Type
