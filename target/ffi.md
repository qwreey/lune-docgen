<!-- markdownlint-disable -->

# FFI

> Note: **This library is technical preview**, not completed yet. Behaviors can be changed in future.

Built-in library for foreign function interface.

### Example usage
lib.c:
```c
int add(int a, int b) {
	return a + b;
}
```
init.luau:
```lua
local ffi = require("@lune/ffi")

-- Create function signature
local addSignature = ffi.c.fn({ ffi.c.int, ffi.c.int }, ffi.c.int)

-- Load library
local lib = ffi.open("./lib.so")

-- Get symbol from library
local addSymbol = lib:find("add")

-- Create CallableData
local add = addSignature:callable(addSymbol)

-- Create result box and arguments
local result = ffi.box(ffi.c.int.size)
local a = ffi.c.int:box(1)
local b = ffi.c.int:box(2)

-- Call external function
add(result, a:ref(), b:ref())

-- Get number from result
print(ffi.c.int:readData(result))
```

## Properties

### C

`C`

Namespace for compile time sized c types.

---

### u8

`CTypeInfo`

A 8-bit sized unsigned integer, Equivalent to `uint8_t` in `stdint`.

---

### u16

`CTypeInfo`

A 16-bit sized unsigned integer, Equivalent to `uint16_t` in `stdint`.

---

### u32

`CTypeInfo`

A 32-bit sized unsigned integer, Equivalent to `uint32_t` in `stdint`.

---

### u64

`CTypeInfo`

A 64-bit sized unsigned integer, Equivalent to `uint64_t` in `stdint`.

---

### u128

`CTypeInfo`

A 128-bit sized unsigned integer, Equivalent to `uint128_t` in `stdint`.

---

### i8

`CTypeInfo`

A 8-bit sized signed integer, Equivalent to `int8_t` in `stdint`.

---

### i16

`CTypeInfo`

A 16-bit sized signed integer, Equivalent to `int16_t` in `stdint`.

---

### i32

`CTypeInfo`

A 32-bit sized signed integer, Equivalent to `int32_t` in `stdint`.

---

### i64

`CTypeInfo`

A 64-bit sized signed integer, Equivalent to `int64_t` in `stdint`.

---

### i128

`CTypeInfo`

A 128-bit sized signed integer, Equivalent to `int128_t` in `stdint`.

---

### f32

`CTypeInfo`

A single-precision 32-bit sized floating-point, Almost always equivalent to `float` in C.

---

### f64

`CTypeInfo`

A double-precision 64-bit sized floating-point, Almost always equivalent to `double` in C.

---

### usize

`CTypeInfo`

A machine specific pointer sized unsigned integer.

---

### isize

`CTypeInfo`

A machine specific pointer sized signed integer.

## Functions

### nullRef

Create a `Ref` with address 0.

Can be used for receive a pointer from external function or pass it as an argument.

#### Returns

- A zero initialized Ref

---

### box

Create a `Box` with specific size.
The created box is not filed with zero.

#### Parameters

- `size` The size of the new box

#### Returns

- A allocated box

---

### open

Open a dynamic library.

#### Parameters

- `name` The name of the target library

#### Returns

- A dynamic library handle

---

### isInteger

Return `true` if the second argument is an integer (i32).

#### Parameters

- `val` A lua value to check

#### Returns

- Whether val is an integer or not

---

### free

Free referenced memory.

#### Parameters

- `data` Target memory to free

# BoxData

A user manageable heap memory.

## Fields

### size

**@readonly** The size of the box.

## Methods

### zero

Fill the box with zero.

#### Returns

- `BoxData` itself for convenience

---

### leak

Create a reference of the box after leaking it.

GC doesn't manage destruction after this action. You must free it later.

#### Parameters

- `offset` Create a reference at the given offset

#### Returns

- A reference of the box

---

### ref

Create a reference of the box.

The created reference keeps the box from being garbage collected until the reference itself is collected.

#### Parameters

- `offset` Create a reference at the given offset

#### Returns

- A reference of the box

---

### copyFrom

Copy content from another data with specific length.

#### Parameters

- `src` The source data
- `length` The amount of data to copy, in bytes
- `dstOffset` The offset in the destination where the content will be pasted
- `srcOffset` The offset in the source data from where the content will be copied

#### Returns

- `BoxData` itself for convenience

---

### readString

Read string from data with specific length without null termination.

#### Parameters

- `length` The amount of data to read, in bytes
- `offset` Offset to read string from

#### Returns

- A string

---

### writeString

Write string into data without null termination.

#### Parameters

- `src` The source string
- `length` The amount of data to write, in bytes
- `dstOffset` The offset in the destination where the content will be pasted
- `srcOffset` The offset in the source string from where the content will be copied

#### Returns

- `BoxData` itself for convenience

# RefData

A user manageable memory reference.

It can be GCed, But it doesn't free the referenced memory.

## Methods

### deref

Create a RefData by dereference this reference.
The created reference has no boundaries and has no restrictions.

This method is unsafe.

#### Returns

- A dereferenced `RefData`

---

### offset

Create a reference with specific offset from this reference.

The created reference can be GCed and holds same data.

#### Parameters

- `offset` Create a reference at the given offset

#### Returns

- A offseted reference

---

### ref

Create a reference of this reference.

The created reference keeps the target reference from being garbage collected until created reference itself is collected.

#### Returns

- A reference of this reference

---

### leak

Create a reference of this reference after leaking it.

GC doesn't manage destruction after this action. You must free it later.

#### Returns

- A reference of this reference

---

### isNull

Check reference is null or not.

#### Returns

- Whether reference is null or not

---

### copyFrom

Copy content from another data with specific length.

#### Parameters

- `src` The source data
- `length` The amount of data to copy, in bytes
- `dstOffset` The offset in the destination where the content will be pasted
- `srcOffset` The offset in the source data from where the content will be copied

#### Returns

- `RefData` itself for convenience

---

### readString

Read string from data with specific length without null termination.

#### Parameters

- `length` The amount of data to read, in bytes
- `offset` Offset to read string from

#### Returns

- A string

---

### writeString

Write string into data without null termination.

#### Parameters

- `src` The source string
- `length` The amount of data to write, in bytes
- `dstOffset` The offset in the destination where the content will be pasted
- `srcOffset` The offset in the source string from where the content will be copied

#### Returns

- `RefData` itself for convenience
