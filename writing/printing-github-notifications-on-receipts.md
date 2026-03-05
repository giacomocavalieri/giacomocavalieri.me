---
id = "todo"
title = "todo"
abstract = "todo"
preview-image = "todo.jpg"
tags = ["gleam", "testing"]
date = 2026-03-03
status = "show"
---

```=html
<video
  muted loop autoplay
  poster='/imgs/raspberry-display-poster.png'
  preload='auto'>
    <source type='video/mp4' src='/imgs/thermal-printer.mp4' />
</video>
```

Last week, inspired by a lightning talk I saw at the
[Gleam Gathering](https://gleamgathering.com), I decided to buy a cheap thermal
printer and see if I could make it print all sort of things.

It is now set up to print pictures, receipts whenever some of my projects get a
star on GitHub, and (the most fun of all) _messages from strangers on the internet!_
You can actually send me any message using the form below: anything you submit
in there will be printed anonymously by the thermal printer that is now sitting
at my desk.

```=html
<blockquote id="carrier-pigeon">
<script src="/js/carrier_pigeon.js" type="module"></script>
</blockquote>
```

So let's have a look at how these printers work, how I set everything up, and
how you can do the same!

## The ESC/POS protocol

Many thermal printers support the [ESC/POS protocol.](https://download4.epson.biz/sec_pubs/pos/reference_en/escpos/index.html)
By sending specific bytes over to the printer we can have it print all sorts of
messages, even pictures!

The first command to send the printer initialises it, it's called
[`ESC @`](https://download4.epson.biz/sec_pubs/pos/reference_en/escpos/esc_atsign.html)
and consists of two bytes: `27` and `64`.
Gleam has some handy syntax to build sequences of binary data, this is what it
looks like:

```gleam
pub fn main() {
  let initialise = <<27, 64>>

  todo as "send the command over to the printer"
}
```

Now, how do we print some text? The process is pretty straightforward: send the
text ascii bytes over to the printer, followed by a `\r\n`.
For example the message `"abc"` would be the bytes `<<97, 98, 99>>`.
The problem is decyphering those bytes in our code gets really hard, especially
with long messages!
Gleam has some nice syntax that allows us to write a string directly, turning it
into its utf8-encoded bytes:

```gleam
pub fn main() {
  let initialise = <<27, 64>>
  let message = <<"Hello, world!\r\n">>
  //                            ^^
  //  Don't forget the carriage return!

  todo as "send the command over to the printer"
}
```

So far so good... let's try and step up our printing game and print a barcode!
That can be achieved with the [`GS k`](https://download4.epson.biz/sec_pubs/pos/reference_en/escpos/gs_lk.html)
command.
The documentation is a bit dense so let me break it down for you:

- First we need to send two bytes: `29` and `107`, this is to tell the printer
  we want to print a barcode.
- Then we need to send a single byte (they call it `m`) which is used to decide
  which kind of barcode system we're using, the table they have in their docs is
  surprisingly quite nice at explaining the different systems.
- Next comes the ascii bytes that are describing the content of the barcode,
  depending on the system we picked with the `m` byte those might be just
  numbers, or numbers and letters.
- We end the command by sending over a `0` byte.

So let's try and wrap everything together by printing the
[EAN-13](https://it.wikipedia.org/wiki/European_Article_Number) of a book:

```gleam
pub fn main() {
  let initialise = <<27, 64>>
  let message = <<"Hello, world!\r\n">>
  let barcode = <<
    29, 107,         // 1. "GS k" command code
    2,               // 2. the barcode is an EAN-13
    "9781449320737", // 3. the ascii content of the barcode
    0                // 4. terminating byte
  >>

  todo as "send the command over to the printer"
}
```

Not that scary after all!
And we can combine all those commands into a single sequence of bytes to send
over to the printer like this:

```gleam
pub fn main() {
  let initialise = <<27, 64>>
  let message = <<"Hello, world!\r\n">>
  let barcode = <<29, 107, 2, "9781449320737", 0>>
  let commands = <<initialise:bits, message:bits, barcode:bits>>
  todo as "send the command over to the printer"
}
```

But now we need to take care of that `todo` looming at the end of our code...
how does one send these bytes over to an actual printer?

## One does not simply print

The thermal printer I have is a cheap PT-280 one can connect to over bluetooth.
In my setup I'm connecting it to my [Raspberry Pi Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/)
that I use as a little home server.
The code I'm showing here will most likely work with any model that supports
bluetooth connection.

Using the `bluetoothctl` command we first start looking for the device:

```sh
bluetoothctl power on
bluetoothctl agent on
bluetoothctl --timeout 3 scan on
```

In the command output you should be able to see a line with the name of your
device (in my case it's `"PT-280"`) and its address, something that looks like
this:

```=html
<pre><code data-highlighted='yes' class='not-prose language-shell'><span class='hljs-comment'># ... other devices</span>
[<span class='hljs-shell-new'>NEW</span>] Device 86:67:7A:DF:F3:FC PT-280
<span class='hljs-comment'># ... other devices</span></code>
</pre>
```

Once you have the printer address (`86:67:7A:DF:F3:FC` in my case) you can pair
and trust the device:

```sh
bluetoothctl pair 86:67:7A:DF:F3:FC
bluetoothctl trust 86:67:7A:DF:F3:FC
```

The only thing that's left to do is bind the printer to an RFCOMM device
creating a virtual serial port we can write to as if it were a file:

```sh
sudo rfcomm bind 0 86:67:7A:DF:F3:FC 1
```

Phew! The hard bit is out of the way.
What's nice is we can now send those bytes to the printer the same way we would
write to a file.

```gleam
// In Gleam you can use the simplifile package,
// add it to your project by running `gleam add simplifile`.
import simplifile

pub fn main() {
  let initialise = <<27, 64>>
  let message = <<"Hello, world!\r\n">>
  let barcode = <<29, 107, 2, "9781449320737", 0>>
  let commands = <<initialise:bits, message:bits, barcode:bits>>
  simplifile.write_bits(commands, to: "/dev/rfcomm0")
}
```

I think this is quite remarkable, in about 5 lines of code we managed to print
some text and a barcode using a thermal printer!
And here's the print in all its glory.

<TODO AGGIUNGI IMMAGINE>

## The sky's the limit

Now that everything is set up we can start experimenting with more commands.
First let's center align the text with the [`ESC a`](https://download4.epson.biz/sec_pubs/pos/reference_en/escpos/esc_la.html)
command.
It consists of the two bytes `27` and `97`, followed by one additional byte that
can either have the value `0` (left-alignment), `1` (center-alignment), or
`2` (right-alignment):

```diff
 import simplifile

 pub fn main() {
   let initialise = <<27, 64>>
+  let center_align = <<27, 97, 1>>
   let message = <<"Hello, world!\r\n">>
   let barcode = <<29, 107, 2, "9781449320737", 0>>
   let commands = <<
     initialise:bits,
+    center_align:bits,
     message:bits,
     barcode:bits,
   >>
   simplifile.write_bits(commands, to: "/dev/rfcomm0")
 }
```

We can also play around with the font width and height using the
[`GS !`](https://download4.epson.biz/sec_pubs/pos/reference_en/escpos/gs_exclamation.html)
command: it starts with two bytes `29` and `33`, then it's followed by a single
byte. Its individual bits describe how the font is to be enlarged, let's break
it down:

```
0 aaa 0 bbb
┬ ─┬─ ┬ ─┬─
╰─┄│┄─┴─┄│┄── These two bits are always zero
   ╰────┄│┄── 3-bit number width multiplier
         ╰─── 3-bit number height multiplier
```

The height/width is multiplied by the value of the corresponding 3-bit number,
plus one. So `0b000` corresponds to 1x, `0b001` to 2x, `0b010` to 3x, and so
on...

Say we want to make the greeting twice as tall, that means the last byte needs
to be `0b0_001_0_000` (I'm using underscores to split each group of bits and
make it easier to see each one).
We can write that directly in Gleam:

```diff
 import simplifile

 pub fn main() {
   let initialise = <<27, 64>>
   let center_align = <<27, 97, 1>>
+  let enlarge = <<29, 33, 0b0_001_0_000>>
   let message = <<"Hello, world!\r\n">>
   let barcode = <<29, 107, 2, "9781449320737", 0>>
   let commands = <<
     initialise:bits,
     center_align:bits,
+    enlarge:bits,
     message:bits,
     barcode:bits,
   >>
   simplifile.write_bits(commands, to: "/dev/rfcomm0")
 }
```
