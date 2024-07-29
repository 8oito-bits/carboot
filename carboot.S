# by Willian Oliveira
.code16

.equ SCREEN_WIDTH,   320
.equ SCREEN_HEIGHT,  200

.equ ROAD_X, 125
.equ ROAD_WIDTH, 70
.equ ROAD_COLOR, 8

.equ LANE_WIDTH, 2
.equ LANE_HEIGHT, 20
.equ LANE_COLOR, 14

.global _start
.section .text
_start:
  movw  $0xa000, %ax
  movw  %ax, %es
  # %ds vai ficar zerado mesmo
  xorw  %ax, %ax
  movw  %ax, %ds

  movw  $0x13, %ax
  int   $0x10

  xorw %di, %di
  movb $2, %al
  movw $(SCREEN_WIDTH * SCREEN_HEIGHT), %cx 
  rep  stosb

  movw  $ROAD_COLOR, %di
  movw  $0, %si
  movw  $ROAD_X, %bx
  movw  $ROAD_WIDTH, %dx
  movw  $SCREEN_HEIGHT, %ax
  call  draw_rectangle

.l4:

  leaw  car_bitmap, %di
  movw  player_car_y, %si
  movw  player_car_x, %bx
  movw  $4, %dx
  call  draw_bitmap

  cmpw  $500, delay
  jne   .stop_car
  movw  $0x0, delay
  movb  $0x2, %ah
  int   $0x16

  cmpw  $ROAD_X, %bx
  je    .right     
  cmpb  $4, %al
  je    .left 

.right:
  
  cmpw  $(ROAD_X + ROAD_WIDTH - 8), %bx
  je    .stop_car                     
  cmpb  $8, %al
  jne   .stop_car
  movw  $8, %dx
  callw erase_bitmap
  incw  player_car_x

  jmp   .stop_car 

.left:
  movw  $8, %dx
  callw erase_bitmap
  decw  player_car_x
.stop_car:
  incw  delay
  xorb  %al, %al

  leaw  lane_y, %cx
  movw  $LANE_COLOR, %di
.l7:
  movw  %cx, %si
  movw  (%si), %si
  addw  $2, %cx
  movw  $159, %bx
  movw  $LANE_WIDTH, %dx
  movw  $LANE_HEIGHT, %ax
  callw draw_lane

  cmpw  $lane_y + 10, %cx
  jne   .l7
 
  incw  delay2
  cmpw  $1000, delay2
  jne   .l4
  movw  $0x0, delay2

  leaw  lane_y, %cx
  movw  $ROAD_COLOR, %di
.l9:
  movw  %cx, %si
  movw  (%si), %si
  addw  $2, %cx
  callw draw_lane

  cmpw  $lane_y + 10, %cx
  jne   .l9

  leaw  lane_y, %bx
.l8:
  addw  $1, (%bx)
  cmpw  $SCREEN_HEIGHT, (%bx)
  jne    .l12
  movw  $-LANE_HEIGHT, (%bx)
.l12:
  addw  $2,  %bx
  cmpw  $lane_y + 10, %bx
  jne   .l8 

.stop_lane:
  
  jmp   .l4

draw_bitmap:
  pushaw
 
  movw  %bx, %bp 
  movb  $0x80, %cl
  movw  $8, %ax
  jmp   .l2
.l1:
  shrb  $1, %cl
  incw  %bx
.l2:
  testb  %cl, %cl
  jz    .l3
  testb  %cl, (%di)
  jz    .l1

  xchgw %dx, %di
  call  plot_pixel 
  xchgw %dx, %di 
  jmp   .l1
.l3:
  incw  %si
  incw  %di
  movb  $0x80, %cl
  movw  %bp, %bx
  decw  %ax  

  test  %ax, %ax
  jne   .l2
  popaw
  ret

erase_bitmap:
  call  draw_bitmap
  ret

draw_rectangle:
  pushaw

  movw  %bx, %cx
  movw  %dx, %bp

.l0:
  callw plot_pixel
  incw  %bx
  decw  %dx
  test  %dx, %dx
  jne   .l0
  movw  %cx, %bx
  movw  %bp, %dx
  incw  %si
  decw  %ax
  test  %ax, %ax
  jne   .l0

  popaw
  ret  

get_pixel_color:
  pushw %di
  pushw %dx
  pushw %si
  pushw %bx

  xorw  %dx, %dx
  movw  $SCREEN_WIDTH, %ax
  mulw  %di
  movw  %ax, %di
  movb  %es:(%bx, %di), %al

  
  popw  %bx
  popw  %si
  popw  %dx
  popw  %di
  ret

draw_lane:
  pushaw

  movw  %bx, %cx
  movw  %dx, %bp


.l5:
  pushw %ax  
  xchgw %di, %si
  callw get_pixel_color
  xchgw %di, %si
  cmpb  $LANE_COLOR, %al
  je    .l10
  cmpb  $ROAD_COLOR, %al
  popw  %ax
  jne   .l6
.l11:
  callw plot_pixel
.l6:
  incw  %bx
  decw  %dx
  test  %dx, %dx
  jne   .l5
  movw  %cx, %bx
  movw  %bp, %dx
  incw  %si
  decw  %ax
  test  %ax, %ax
  jne   .l5

  popaw
  ret

.l10:
  popw  %ax
  jmp   .l11

plot_pixel:
  pushaw

  xorw  %dx, %dx
  movw  $SCREEN_WIDTH, %ax
  mulw  %si
  movw  %ax, %si
  movw  %di, %dx
  movb  %dl, %es:(%bx, %si)

  popaw
  ret

car_bitmap: .byte 0x3c, 0x3c, 0xff, 0xff, 0x3c, 0x3c, 0xff, 0xff
player_car_x: .word 156
player_car_y: .word 180

lane_y: .word 0, 40, 80, 120, 160

delay:  .word 0
delay2: .word 0
. = _start + 510
.word 0xaa55
