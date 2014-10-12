require 'gosu'

module ZOrder
  Player = *0..3
end

class GameWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Gosu Tutorial Game"

    @background_image = Gosu::Image.new(self, "space.jpg", true)
    @player = Ship.new(self)
    @player.warp(320, 240)
    @missiles = 100.times.map { Missile.new(self, 0, 0, 0) }
    @missiles_on_screen = []
  end

  def update
    if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      @player.turn_left
    end
    if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      @player.turn_right
    end
    if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      @player.accelerate
    end

    if button_down? Gosu::KbSpace
      @player.fire_missile!(@missiles.reject{|m| m.live? }.first)
    end
    @player.move
    @missiles.each{|m| m.move if m.live? }
  end

  def draw
    @player.draw
    @background_image.draw(0,0,0)
    @missiles.each { |m| m.draw if m.live? }
  end
end

class Ship
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(window, "ship0.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
    @animation = (0..3).map {|i| Gosu::Image.new(window, "ship#{i}.png", false) }
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    img = @animation[Gosu::milliseconds / 100 % @animation.size]
    img.draw_rot(@x, @y, 1, @angle)
  end

  def fire_missile!(m)
    m.assign!(@angle)
    m.live = true
    m.warp(@x, @y)
    m
  end
end

class Missile
  SPEED = 1.2
  attr_accessor :live
  def initialize(window, velx, vely, angle)
    @image = Gosu::Image.new(window, "missile.png", false)
    @x = @y = 0.0
    @angle = angle
    @vel_x = Gosu::offset_x(@angle, 2.5)
    @vel_y = Gosu::offset_y(@angle, 2.5)
    @live = false
  end

  def live?
    @live
  end

  def assign!(angle)
    @angle = angle
    @vel_x = Gosu::offset_x(@angle, 2.5)
    @vel_y = Gosu::offset_y(@angle, 2.5)
  end

  def warp(x,y)
    @x, @y = x,y
  end

  def move
    @x += @vel_x
    @y += @vel_y
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def off_screen?(w, h)
    @x > w || @y > h || @x < 0 || @y < 0
  end
end



window = GameWindow.new
window.show
