import unittest, sequtils
import nlibc

template `&`[T](v: var T): untyped =
  v.addr

template `&`[T](v: T): untyped =
  v.unsafeAddr

suite "string_h":
  test "strlen":
    let str = "abcdefghinkljmnopqrstuvwxyz"
    check(str.len == cstring(str).strlen)

  test "memcmp single byte pointers":
    let (a, b, c) = (0xFA'u8, 0xEF'u8, 0xFE'u8)
    check(memcmp(&a, &a, 1) == 0x00)
    check(memcmp(&b, &c, 1) < 0x00)

  test "memcmp strings":
    block:
      let (x, z) = ("Hello!", "Good Bye.")
      check(memcmp(&x[0], &x[0], x.len) == 0)
      check(memcmp(&x[0], &z[0], x.len) > 0)
      check(memcmp(&z[0], &x[0], x.len) < 0)
    block:
      let (x, z) = ("hey!", "hey.")
      check(memcmp(&x[0], &z[0], x.len) < 0)

  test "memset single byte pointers":
    var x = 0xFF'u8
    discard memset(&x, 0xAA, 1)
    check(x == 0xAA)
    discard memset(&x, 0x00, 1)
    check(x == 0x00)
    x = 0x01
    discard memset(&x, 0x12, 0)
    check(x == 0x01)

  test "memset array/seq":
    var buf = newSeqWith(100, 'X')
    discard memset(&buf[0], '#'.cint, buf.len)
    for b in buf: check(b == '#')

  test "memcpy and memcmp arrays/seqs":
    let src = newSeqWith(100, 'X')
    var dst = newSeqWith(100, 'Y')
    check(memcmp(&src[0], &dst[0], 100) != 0)
    discard memcpy(&dst[0], &src[0], 100)
    check(memcmp(&src[0], &dst[0], 100) == 0)

  test "memmove overlapping":
    block:
      var buf = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
      discard memmove(&buf[4], &buf[0], 6)
      var i = 0
      for b in "0123012345":
        check(buf[i] == b)
        i += 1
    block:
      var buf = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
      discard memmove(&buf[0], &buf[4], 6)
      var i = 0
      for b in "4567896789":
        check(buf[i] == b)
        i += 1
