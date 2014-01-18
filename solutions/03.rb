module Graphics
  class Canvas
    def initialize(width, height)
      @width = width
      @height = height
      @pixels = []
    end

    attr_reader :width, :height

    def set_pixel(x, y)
      @pixels << [x, y] unless @pixels.include? [x, y]
    end

    def pixel_at?(x, y)
      @pixels.include? [x, y]
    end

    def draw(shape)
      shape.draw(self)
    end

    def render_as(renderer)
      renderer.new.set_render(self)
    end
  end

  module Renderers
    class Ascii
      def set_render(pane)
        panel = ""
        0.upto(pane.width * pane.height - 1) do |x|
          panel += "\n" if (x).remainder(pane.width).zero? and not x == 0
          panel += '-'
          panel[panel.length - 1] = '@' if pane.pixel_at? x % pane.width, x / pane.width
        end
        panel
      end
    end

    class Html
      PANEL_FIRST_PART = "
                  <!DOCTYPE html>
                  <html>
                  <head>
                    <title>Rendered Canvas</title>
                    <style type=\"text/css\">
                      .canvas {
                      font-size: 1px;
                      line-height: 1px;
                    }
                    .canvas * {
                      display: inline-block;
                      width: 10px;
                      height: 10px;
                      border-radius: 5px;
                    }
                    .canvas i {
                      background-color: #eee;
                    }
                    .canvas b {
                      background-color: #333;
                    }
                    </style>
                  </head>
                  <body>
                    <div class=\"canvas\">\n"

      PANEL_SECOND_PART = "
                    </div>
                  </body>
                  </html>"

      def set_canvas(pane, count, pixel = "")
        pixel += "<br>\n" if (count).remainder(pane.width).zero? and not count == 0
        if pane.pixel_at? count % pane.width, count / pane.width
          pixel += "<b></b>"
        else
          pixel += "<i></i>"
        end
        pixel
      end

      def set_render(pane)
        panel = PANEL_FIRST_PART
        0.upto(pane.width * pane.height - 1) do |x|
           panel += set_canvas(pane, x)
        end
        panel += PANEL_SECOND_PART
      end
    end
  end

  class Point
    def initialize(x, y)
      @x = x
      @y = y
    end

    attr_reader :x, :y

    def ==(point)
      x == point.x and y == point.y
    end

    alias_method :eql?, :==

    def draw(canvas)
      canvas.set_pixel(x, y)
    end

    def hash
      [x, y].hash
    end
  end

  class Line
    def initialize(from_point, to_point)
      @from_point = from_point
      @to_point = to_point
    end

    def from
      if @from_point.x == @to_point.x
        @from_point.y < @to_point.y ? @from_point : @to_point
      else
        @from_point.x < @to_point.x ? @from_point : @to_point
      end
    end

    def to
      if @from_point.x == @to_point.x
        @from_point.y > @to_point.y ? @from_point : @to_point
      else
        @from_point.x > @to_point.x ? @from_point : @to_point
      end
    end

    def ==(line)
      from == line.from and to == line.to
    end

    alias_method :eql?, :==

    def draw_by_y(canvas, length_x, length_y)
      from.y.upto(to.y) do |y|
        x = (from.x + length_x * (y - from.y) / length_y).abs
        canvas.set_pixel(x, y)
      end
    end

    def draw_by_x(canvas, length_x, length_y)
      from.x.upto(to.x) do |x|
        y = (from.y + length_y * (x - from.x) / length_x).abs
        canvas.set_pixel(x, y)
      end
    end

    def draw(canvas)
      length_x, length_y = to.x - from.x, to.y - from.y
      if length_x == 0 || length_y >= length_x
        draw_by_y(canvas, length_x, length_y)
      else
        draw_by_x(canvas, length_x, length_y)
      end
    end

    def hash
      [from.hash, to.hash].hash
    end
  end

  class Rectangle
    def initialize(left_point, right_point)
      @left_point = left_point
      @right_point = right_point
    end

    def left
      if @left_point.x == @right_point.x
        @left_point.y < @right_point.y ? @left_point : @right_point
      else
        @left_point.x < @right_point.x ? @left_point : @right_point
      end
    end

    def right
      if @left_point.x == @right_point.x
        @left_point.y > @right_point.y ? @left_point : @right_point
      else
        @left_point.x > @right_point.x ? @left_point : @right_point
      end
    end

    def top_left
      if left.y < right.y
        left
      else
        Point.new left.x, right.y
      end
    end

    def top_right
      if left.y < right.y
        Point.new right.x, left.y
      else
        right
      end
    end

    def bottom_left
      if left.y < right.y
        Point.new left.x, right.y
      else
        left
      end
    end

    def bottom_right
      if left.y < right.y
        right
      else
        Point.new left.x, right.y
      end
    end

    def ==(rectangle)
      top_left == rectangle.top_left and bottom_right == rectangle.bottom_right
    end

    alias_method :eql?, :==

    def draw(canvas)
      canvas.draw Line.new(top_left, top_right)
      canvas.draw Line.new(top_left, bottom_left)
      canvas.draw Line.new(bottom_left, bottom_right)
      canvas.draw Line.new(top_right, bottom_right)
    end

    def hash
      [top_left.hash, bottom_right.hash, bottom_left.hash].hash
    end
  end
end