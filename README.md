# identicon.cr

A Crystal implementation of [ruby_identicon](https://github.com/chrisbranson/ruby_identicon) which is a Ruby implementation of [go-identicon](https://github.com/dgryski/go-identicon).

`identicon.cr` creates an [identicon](https://github.com/dgryski/go-identicon), similar to those created by [Github](https://github.com/blog/1586-identicons). Unfortunately the algorithm Github uses isn't open source, so this isn't the exact same.

A title and key are used by siphash to calculate a hash value that is then used to create a visual identicon representation. The identicon is made by creating a left hand side pixel representation of each bit in the hash value - this is then mirrored onto the right hand side to create an image that we see as a shape. The grid and square sizes can be varied to create identicons of differing size.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     identicon:
       github: watzon/identicon
   ```

2. Run `shards install`

## Usage

First require the library:

```crystal
require "identicon"
```

You can easily generate and save a png identicon:

```crystal
Identicon.create_and_save("myemailaddress@gmail.com", "sample_01.png")
```

Which creates an identicon that looks like this:

![Sample 01](./assets/sample_01.png)

If you don't want to save a file, you can also generate an `IO`:

```crystal
Identicon.create("myemailaddress@gmail.com")
```

This returns an `IO::Memory` containing the raw PNG bytes. If you wish to export a base64 encoded string you can do that too:

```crystal
Identicon.create_base64("myemailaddress@gmail.com")
```

## Options

All of the create methods take a number of different options that can be used to change the appearance of the generated image. The options are:

### `key`

A 16 byte key to be passed to the siphash digest.

### `grid_size`

The number of rows and columns in the identicon. A Github identicon is 5x5, but we default to 7x7.

### `border_size`

The size in pixels to leave as an empty border around the identicon image. Defaults to 35.

### `square_size`

The size in pixels of each square that makes up the identicon. Defaults to 50.

### `background_color`

The `StumpyPNG::RGBA` color to use as the image background.

### `bit_depth`

The bit depth of the generated image. Defaults to 8.

### `color_type`

The color type of the generated image. Defaults to `:rgb_alpha`.

## Contributing

1. Fork it (<https://github.com/watzon/identicon/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Watson](https://github.com/watzon) - creator and maintainer
