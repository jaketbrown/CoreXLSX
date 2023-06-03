#if canImport(Darwin)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#elseif canImport(MSVCRT)
import MSVCRT
#endif

import Foundation
import CoreXLSX

@_cdecl("LLVMFuzzerTestOneInput")
public func test(_ start: UnsafeRawPointer, _ count: Int) -> CInt {
    let fdp = FuzzedDataProvider(start, count)
    do {
        let file = try XLSXFile(data: fdp.ConsumeRemainingData())
        for wbk in try file.parseWorkbooks() {
            for (_, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
                try file.parseWorksheet(at: path)
            }
        }
    }
    catch _ as CoreXLSXError {
        return -1
    }
    catch _ as NSError {
        return -1
    }
    catch let error {
    if error.localizedDescription.contains("operation could not be completed") {
            return -1;
        }
        print("Localized description: \(error.localizedDescription)")
        print(type(of: error))
        exit(EXIT_FAILURE)
    }

    return 0;
}
