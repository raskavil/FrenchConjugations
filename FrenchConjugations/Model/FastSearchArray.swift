import Foundation

struct FastTermSearchStorage<Element> {

    private static var keys: String {
        "abcdefghijklmnopqrstuvwxyz"
    }
    
    private var dataDictionary: [Character: [Element]]
    private let stringKeypath: KeyPath<Element, String>
    
    var array: [Element] {
        dataDictionary.lazy.flatMap { $0.value }
    }
    
    init(array: [Element], stringKeypath: KeyPath<Element, String>) {
        dataDictionary = .init(Self.keys.map { ($0, []) }) { $0 + $1 }
        self.stringKeypath = stringKeypath
        array.forEach { item in
            if let firstCharacter = item[keyPath: stringKeypath].applyingTransform(.stripDiacritics, reverse: false)?.first {
                dataDictionary[firstCharacter]?.append(item)
            }
        }
    }
    
    func filter(with term: String) async -> [Element] {
        await withCheckedContinuation { continuation in
            term.applyingTransform(.stripDiacritics, reverse: false)?.first
                .flatMap { firstCharacter in
                    guard let array = dataDictionary[firstCharacter] else {
                        continuation.resume(with: .success([]))
                        return
                    }
                    if term.count > 1 {
                        DispatchQueue(label: "searchQueue").async {
                            continuation.resume(
                                with: .success(array.filter { $0[keyPath: stringKeypath].starts(with: term) })
                            )
                        }
                    } else {
                        continuation.resume(with: .success(array))
                    }
                }
        }
    }
}
