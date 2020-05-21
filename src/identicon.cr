require "base64"

require "stumpy_png"
require "stumpy_utils"

require "./identicon/*"

module Identicon
  DEFAULT_KEY = Bytes[0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204, 221, 238, 255]
  DEFAULT_GRID_SIZE = 7
  DEFAULT_BORDER_SIZE = 35
  DEFAULT_SQUARE_SIZE = 50
  DEFAULT_BACKGROUND_COLOR = StumpyPNG::RGBA.from_rgb_n(255, 255, 255, 8)
  DEFAULT_BIT_DEPTH = 16
  DEFAULT_COLOR_TYPE = :rgb_alpha

  # Create an identicon png and save it to the given filename.
  #
  # Example:
  # ```
  # >> Identicon.create_and_save("identicons are great!", "test_identicon.png")
  # => result (Boolean)
  # ```
  #
  # Params:
  # `title` - the string value to be represented as an identicon
  # `filename` - the full path and filename to save the identicon png to
  # `options` - additional options for the identicon
  #
  def self.create_and_save(title, filename, **options)
    blob = create(title, **options).rewind.to_slice
    return false if blob == nil
    File.open(filename, "wb") { |f| f.write(blob) }
  end

  # Create an identicon png and return it as a base64 encoded string.
  #
  # Example:
  # ```
  # >> Identicon.create_base64("identicons are great!")
  # => result (String)
  # ```
  #
  # Params:
  # `title` - the string value to be represented as an identicon
  # `options` - additional options for the identicon
  #
  def self.create_base64(title, **options)
    Base64.encode(self.create(title, **options))
  end

  # Create an identicon png and return it as an `IO`.
  #
  # Example:
  # ```
  # >> Identicon.create("identicons are great!")
  # => binary blob (String)
  # ```
  #
  # Params:
  # `title` - the string value to be represented as an identicon
  # `options` - additional options for the identicon
  #
  def self.create(title,
                  key = DEFAULT_KEY,
                  grid_size = DEFAULT_GRID_SIZE,
                  border_size = DEFAULT_BORDER_SIZE,
                  square_size = DEFAULT_SQUARE_SIZE,
                  background_color = DEFAULT_BACKGROUND_COLOR,
                  bit_depth = DEFAULT_BIT_DEPTH,
                  color_type = DEFAULT_COLOR_TYPE)
    hash = SipHash.digest(key, title)

    png = StumpyPNG::Canvas.new(
      (border_size * 2) + (square_size * grid_size),
      (border_size * 2) + (square_size * grid_size)
    )

    # set the foreground color by using the first three bytes of the hash value
    color = StumpyPNG::RGBA.from_rgb(
      (hash & 0xff).to_u16,
      ((hash >> 8) & 0xff).to_u16,
      ((hash >> 16) & 0xff).to_u16
    )

    # remove the first three bytes that were used for the foreground color
    hash >>= 24

    # write the background
    ((border_size * 2) + (square_size * grid_size)).times do |x|
      ((border_size * 2) + (square_size * grid_size)).times do |y|
        png[x, y] = background_color
      end
    end

    # write the colored rectangles
    sqx = sqy = 0
    (grid_size * ((grid_size + 1) // 2)).times do
      if hash & 1 == 1
        x = border_size + (sqx * square_size)
        y = border_size + (sqy * square_size)

        # left hand side
        png.rect(x, y, x + square_size - 1, y + square_size - 1, color, color)

        # mirror right hand side
        x = border_size + ((grid_size - 1 - sqx) * square_size)
        png.rect(x, y, x + square_size - 1, y + square_size - 1, color, color)
      end

      hash >>= 1
      sqy += 1
      if sqy == grid_size
        sqy = 0
        sqx += 1
      end
    end

    buffer = IO::Memory.new
    StumpyPNG.write(png, buffer, bit_depth: bit_depth, color_type: color_type)
    buffer
  end
end

puts Identicon.create_base64("myemailaddress@gmail.com")
