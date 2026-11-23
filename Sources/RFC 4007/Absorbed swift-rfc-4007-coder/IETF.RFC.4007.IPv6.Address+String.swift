#if Coder
    import ASCII
    import Byte

    extension IETF.RFC.`4007`.IPv6.Address: CustomStringConvertible {

        public var description: String {
            String(ascii: self)
        }
    }

    extension IETF.RFC.`4007`.IPv6.Address: LosslessStringConvertible {

        public init?(_ description: String) {
            do throws(Error) {
                try self.init(ascii: description.utf8.map(Byte.init(bitPattern:)))
            } catch {
                return nil
            }
        }
    }

    extension IETF.RFC.`4007`.IPv6.Address: Swift::RawRepresentable {

        public var rawValue: String { description }

        public init?(rawValue: String) {
            self.init(rawValue)
        }
    }
#endif
