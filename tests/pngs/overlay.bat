ffmpeg -y -loop 1 -framerate 60 -t 5 -i bg.png -c:v libx264 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" bg.mp4
ffmpeg -y -i bg.mp4 -i output.mkv -filter_complex "[0:v][1:v]overlay=0:0" result.mp4