SuperStrict

Framework SDL.SDLRenderMax2D
Import Video.Mpeg1
Import Audio.AudioSDL
Import brl.standardio


Graphics 1024, 768, 0


Local handler:TVideoHandler = New TVideoHandler

Local mpg:TMpeg1 = TMpeg1.Load("timer.mpg", handler)
 
'mpg.SetLoop(True)

Print "Dimension : " + mpg.Width() + ", " + mpg.Height()
Print "Framerate : " + mpg.Framerate()


Local displayWidth:Int = 1024 - 20
Local displayHeight:Int = 768 - 20
Local imageWidth:Int = mpg.Width()
Local imageHeight:Int = mpg.Height()

Local scaleX:Float = displayWidth / Float(imageWidth)
Local scaleY:Float = displayHeight / Float(imageHeight)

Local scale:Float = Min(scaleX, scaleY)

Setcolor 255, 255, 255

Local last_time:Double = millisecs() / 1000.0

Local count:Int
While Not Keydown(KEY_ESCAPE)

	Local current_time:Double = millisecs() / Double(1000.0)
	Local elapsed_time:Double = current_time - last_time
	if elapsed_time > 1.0 / 30.0 Then
		elapsed_time = 1.0 / 30.0
	End If
	last_time = current_time
	Local video_time:Double = mpg.GetTime()
	
	Cls

	If Not mpg.HasEnded() Then
		mpg.Decode(elapsed_time)
	End If

	SetScale(scale, scale)
	MidHandleImage( handler.image )

	DrawImage handler.image, 1024 / 2, 768 / 2

	SetScale(1, 1)

	SetColor 0, 0, 0
	DrawText(current_time, 11, 11)
	DrawText(video_time, 11, 31)
	DrawText()
	DrawText(elapsed_time, 11, 51)

	SetColor 255, 255, 255
	DrawText(current_time, 10, 10)
	DrawText(video_time, 10, 30)
	DrawText(elapsed_time, 10, 50)

	If mpg.HasEnded() Then
		SetColor 0, 0, 0
		DrawText("End of video", displayWidth / 2 - 50 + 2, displayHeight / 2 + 2)
		SetColor 255, 255, 255
		DrawText("End of video", displayWidth / 2 - 50, displayHeight / 2)
	End If

	Flip

Wend

Type TVideoHandler Implements IVideoHandler

	Field image:TImage
	Field sound:TSound
	Field channel:TChannel

	Method New()
	End Method

	Method Pixmap:TPixmap(width:Int, height:Int, format:Int)
		Local pix:TPixmap = TPixmap.Create(width, height, format)
		image = LoadImage(pix, 0)
		pix = image.Lock(0, False, True)
		Return pix
	End Method

	Method VideoCallback(pix:TPixmap)
		image.Lock(0, False, True)
	End Method

	Method AudioCallback(frame:SMpeg1Samples Ptr)

		Local source:TSLQueued = TSLQueued(TSoloudSound(sound)._sound)

		Local size:Int = 4 * frame.count * 2

		source.writeData(frame.interleaved, size_T(size))

		If Not channel.Playing() Then
			channel.SetPaused(False)
		End If
	End Method

	Method InitAudio(mpg:TMpeg1)
		sound = LoadSound(Null, SOLOUD_SOUND_QUEUED)
		channel = CueSound(sound)
		TSoloudChannel(channel).SetRate(mpg.Samplerate())
	End Method
	
End Type
