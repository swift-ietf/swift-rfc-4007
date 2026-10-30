#if Coder
    import ASCII
    import Byte

    extension RFC_4007.IPv6.ScopedAddress: CustomStringConvertible {

        public var description: String {
            String(ascii: self)
        }
    }

    extension RFC_4007.IPv6.ScopedAddress: LosslessStringConvertible {

        public init?(_ description: String) {
            do throws(Error) {
                try self.init(ascii: description.utf8.map(Byte.init(bitPattern:)))
            } catch {
                return nil
            }
        }
    }

    extension RFC_4007.IPv6.ScopedAddress: Swift::RawRepresentable {

        public var rawValue: String { description }

        public init?(rawValue: String) {
            self.init(rawValue)
        }
    }
#endif
