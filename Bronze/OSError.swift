//
//  OSError.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-17.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation



public struct OSError : CustomStringConvertible {
    let error: Int32

    public var description: String {
        let errorText = OSError.strerrorText(self.error)
        let errorCode = OSError.strerrorCode(self.error)

        return "\(errorCode)(\(self.error)): \(errorText)"
    }

    init(error: Int32) {
        self.error = error
    }

    init() {
        self.error = Foundation.errno
    }

    static func strerrorCode(error: Int32) -> String {
        switch error {
        case EPERM: return "EPERM"
        case ENOENT: return "ENOENT"
        case ESRCH: return "ESRCH"
        case EINTR: return "EINTR"
        case EIO: return "EIO"
        case ENXIO: return "ENXIO"
        case E2BIG: return "E2BIG"
        case ENOEXEC: return "ENOEXEC"
        case EBADF: return "EBADF"
        case ECHILD: return "ECHILD"
        case EAGAIN: return "EAGAIN"
        case ENOMEM: return "ENOMEM"
        case EACCES: return "EACCES"
        case EFAULT: return "EFAULT"
        case ENOTBLK: return "ENOTBLK"
        case EBUSY: return "EBUSY"
        case EEXIST: return "EEXIST"
        case EXDEV: return "EXDEV"
        case ENODEV: return "ENODEV"
        case ENOTDIR: return "ENOTDIR"
        case EISDIR: return "EISDIR"
        case EINVAL: return "EINVAL"
        case ENFILE: return "ENFILE"
        case EMFILE: return "EMFILE"
        case ENOTTY: return "ENOTTY"
        case ETXTBSY: return "ETXTBSY"
        case EFBIG: return "EFBIG"
        case ENOSPC: return "ENOSPC"
        case ESPIPE: return "ESPIPE"
        case EROFS: return "EROFS"
        case EMLINK: return "EMLINK"
        case EPIPE: return "EPIPE"
        case EDOM: return "EDOM"
        case ERANGE: return "ERANGE"
        case EDEADLK: return "EDEADLK"
        case ENAMETOOLONG: return "ENAMETOOLONG"
        case ENOLCK: return "ENOLCK"
        case ENOSYS: return "ENOSYS"
        case ENOTEMPTY: return "ENOTEMPTY"
        case ELOOP: return "ELOOP"
        case ENOMSG: return "ENOMSG"
        case EIDRM: return "EIDRM"
        case ENOSTR: return "ENOSTR"
        case ENODATA: return "ENODATA"
        case ETIME: return "ETIME"
        case ENOSR: return "ENOSR"
        case EREMOTE: return "EREMOTE"
        case ENOLINK: return "ENOLINK"
        case EPROTO: return "EPROTO"
        case EMULTIHOP: return "EMULTIHOP"
        case EBADMSG: return "EBADMSG"
        case EOVERFLOW: return "EOVERFLOW"
        case EILSEQ: return "EILSEQ"
        case EUSERS: return "EUSERS"
        case ENOTSOCK: return "ENOTSOCK"
        case EDESTADDRREQ: return "EDESTADDRREQ"
        case EMSGSIZE: return "EMSGSIZE"
        case EPROTOTYPE: return "EPROTOTYPE"
        case ENOPROTOOPT: return "ENOPROTOOPT"
        case EPROTONOSUPPORT: return "EPROTONOSUPPORT"
        case ESOCKTNOSUPPORT: return "ESOCKTNOSUPPORT"
        case EOPNOTSUPP: return "EOPNOTSUPP"
        case EPFNOSUPPORT: return "EPFNOSUPPORT"
        case EAFNOSUPPORT: return "EAFNOSUPPORT"
        case EADDRINUSE: return "EADDRINUSE"
        case EADDRNOTAVAIL: return "EADDRNOTAVAIL"
        case ENETDOWN: return "ENETDOWN"
        case ENETUNREACH: return "ENETUNREACH"
        case ENETRESET: return "ENETRESET"
        case ECONNABORTED: return "ECONNABORTED"
        case ECONNRESET: return "ECONNRESET"
        case ENOBUFS: return "ENOBUFS"
        case EISCONN: return "EISCONN"
        case ENOTCONN: return "ENOTCONN"
        case ESHUTDOWN: return "ESHUTDOWN"
        case ETOOMANYREFS: return "ETOOMANYREFS"
        case ETIMEDOUT: return "ETIMEDOUT"
        case ECONNREFUSED: return "ECONNREFUSED"
        case EHOSTDOWN: return "EHOSTDOWN"
        case EHOSTUNREACH: return "EHOSTUNREACH"
        case EALREADY: return "EALREADY"
        case EINPROGRESS: return "EINPROGRESS"
        case ESTALE: return "ESTALE"
        case EDQUOT: return "EDQUOT"
        case ECANCELED: return "ECANCELED"
        case EOWNERDEAD: return "EOWNERDEAD"
        case ENOTRECOVERABLE: return "ENOTRECOVERABLE"
        default: break
        }

    #if os(Linux)
        switch error {
        case ECHRNG: return "ECHRNG"
        case EL2NSYNC: return "EL2NSYNC"
        case EL3HLT: return "EL3HLT"
        case EL3RST: return "EL3RST"
        case ELNRNG: return "ELNRNG"
        case EUNATCH: return "EUNATCH"
        case ENOCSI: return "ENOCSI"
        case EL2HLT: return "EL2HLT"
        case EBADE: return "EBADE"
        case EBADR: return "EBADR"
        case EXFULL: return "EXFULL"
        case ENOANO: return "ENOANO"
        case EBADRQC: return "EBADRQC"
        case EBADSLT: return "EBADSLT"
        case EBFONT: return "EBFONT"
        case ENONET: return "ENONET"
        case ENOPKG: return "ENOPKG"
        case EADV: return "EADV"
        case ESRMNT: return "ESRMNT"
        case ECOMM: return "ECOMM"
        case EDOTDOT: return "EDOTDOT"
        case ENOTUNIQ: return "ENOTUNIQ"
        case EBADFD: return "EBADFD"
        case EREMCHG: return "EREMCHG"
        case ELIBACC: return "ELIBACC"
        case ELIBBAD: return "ELIBBAD"
        case ELIBSCN: return "ELIBSCN"
        case ELIBMAX: return "ELIBMAX"
        case ELIBEXEC: return "ELIBEXEC"
        case ERESTART: return "ERESTART"
        case ESTRPIPE: return "ESTRPIPE"
        case EUCLEAN: return "EUCLEAN"
        case ENOTNAM: return "ENOTNAM"
        case ENAVAIL: return "ENAVAIL"
        case EISNAM: return "EISNAM"
        case EREMOTEIO: return "EREMOTEIO"
        case ENOMEDIUM: return "ENOMEDIUM"
        case EMEDIUMTYPE: return "EMEDIUMTYPE"
        case ENOKEY: return "ENOKEY"
        case EKEYEXPIRED: return "EKEYEXPIRED"
        case EKEYREVOKED: return "EKEYREVOKED"
        case EKEYREJECTED: return "EKEYREJECTED"
        default: break
        }
    #endif

        return "EUNKNOWN"
    }

    static func strerrorText(error: Int32) -> String {
        let errorStringMemory = Foundation.strerror(error)
        if let errorString = String(UTF8String: errorStringMemory) {
            return errorString
        } else {
            return "Unknown error."
        }
    }
}

public enum OptionalOSError<T> {
case Success(T)
case Error(OSError)
}

public func ~=(pattern: Int32, x: OSError) -> Bool {
    return pattern == x.error
}
