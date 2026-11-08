#if Coder
    import ASCII
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension RFC_4007.IPv6.ScopedAddress {
        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {
            public init() {}
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }

    extension RFC_4007.IPv6.ScopedAddress.Coder {
        public typealias Output = RFC_4007.IPv6.ScopedAddress

        public typealias Failure = RFC_4007.IPv6.ScopedAddress.Error

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            let bytes = Scan.run(&input, while: Self.isScopedAddressByte)
            do throws(Failure) {
                return try RFC_4007.IPv6.ScopedAddress(ascii: bytes)
            } catch {
                input.seek(to: start)
                throw error
            }
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            buffer.append(contentsOf: output.serialized)
        }

        static func isScopedAddressByte(_ byte: UInt8) -> Bool {
            switch byte {
            case 0x30...0x39, 0x41...0x5A, 0x61...0x7A, 0x25, 0x2D, 0x2E, 0x3A, 0x5F:
                return true
            default:
                return false
            }
        }
    }
#endif
