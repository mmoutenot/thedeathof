$(document).ready ->
  ctx = demo.getContext '2d'
  w = demo.width
  h = demo.height

  px = 0
  opx = 0
  speed = 3

  py = h * 0.8
  opy = py

  scanBarWidth = 20

  ctx.canvas.width  = window.innerWidth
  ctx.canvas.height = window.innerHeight

  ctx.strokeStyle = '#00bd00'
  ctx.lineWidth = 3

  demo.onmousemove = (e) ->
    r = demo.getBoundingClientRect()
    py = e.clientY - r.top

  draw = () ->
    px += speed

    ctx.clearRect px, 0, scanBarWidth, ctx.canvas.height
    ctx.beginPath()
    ctx.moveTo opx, opy
    ctx.lineTo px, py
    ctx.stroke()

    opx = px
    opy = py

    if  opx > ctx.canvas.width
      px = opx = -speed

    requestAnimationFrame draw

  draw()
