require 'gosu'

class GameWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Gosu Tutorial Game"

    @background_image = Gosu::Image.new(self, "space.jpg", true)
    @player = Ship.new(self)
    @player.warp(320, 240)
    @player2 = Ship.new(self)
    @player2.warp(120, 240)
    @missiles = 100.times.map { Missile.new(self, 0, 0, 0) }
    @missiles_on_screen = []
  end

  def update
    @player.turn_left  if button_down? Gosu::KbLeft
    @player.turn_right if button_down? Gosu::KbRight
    @player.accelerate if button_down? Gosu::KbUp

    @player2.turn_left  if button_down? Gosu::KbH
    @player2.turn_right if button_down? Gosu::KbL
    @player2.accelerate if button_down?(Gosu::KbJ)

    if button_down? Gosu::KbSpace
      missile = @missiles.reject{|m| m.live? }.first
      @player.fire_missile!(missile) if missile && @player.can_fire?
    end

    if button_down? Gosu::KbK
      missile = @missiles.reject{|m| m.live? }.first
      @player2.fire_missile!(missile) if missile && @player2.can_fire?
    end

    exit if button_down? Gosu::KbQ

    @player.move
    @player2.move
    @missiles.each do |m|
      m.move if m.live?
      m.live = false if m.off_screen?(640,480)
    end

    collision_detect!([@player, @player2] + @missiles.select{|m| m.live? })
  end

  def draw
    @player.draw
    @player2.draw
    @background_image.draw(0,0,0)
    @missiles.each { |m| m.draw if m.live? }
  end

  def collision_detect!(things)
    things.each do |t|
      things.each do |ot|
        t.asplode! if t.collides_with? ot
      end
    end
  end
end

module Collidable
  attr_reader :x, :y
  def collides_with? other
    return false if other == self
    dx = (@x - other.x).abs
    dy = (@y - other.y).abs
    distance = Math.sqrt(dx ** 2 + dy ** 2 )
    distance < 10
  end
  def asplode!
    raise "Implement asplode dude"
  end
end

class Ship
  include Collidable

  SPEED = 1
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(window, "ship0.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
    @animation = (0..3).map {|i| Gosu::Image.new(window, "ship#{i}.png", false) }
    @last_fired_at = Time.now
  end

  def asplode!
    @x = @y = 0
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

    @vel_x = SPEED if @vel_x > SPEED
    @vel_y = SPEED if @vel_y > SPEED
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

  def can_fire?(time=Time.now)
    time - @last_fired_at > 0.2
  end

  def fire_missile!(m)
    @last_fired_at = Time.now
    m.assign!(@angle)
    m.live = true
    xoff = Gosu::offset_x(@angle, 20)
    yoff = Gosu::offset_y(@angle, 20)
    m.warp(@x + xoff , @y + yoff)
    m
  end
end

class Missile
  include Collidable
  SPEED = 3
  attr_accessor :live
  def initialize(window, velx, vely, angle)
    @image = Gosu::Image.new(window, "missile.png", false)
    @x = @y = 0.0
    @angle = angle
    @vel_x = Gosu::offset_x(@angle, SPEED)
    @vel_y = Gosu::offset_y(@angle, SPEED)
    @live = false
  end

  def live?
    @live
  end

  def assign!(angle)
    @angle = angle
    @vel_x = Gosu::offset_x(@angle, SPEED)
    @vel_y = Gosu::offset_y(@angle, SPEED)
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

  def asplode!
    @live = false
  end
end

class Asteroid
end

window = GameWindow.new
window.show
