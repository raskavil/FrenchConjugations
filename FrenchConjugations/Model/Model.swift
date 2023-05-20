import SwiftUI
import SupportPackage

class ViewModel: ObservableObject {
    
    @Published var displayedConjugations: [Conjugation] = []
    @Published var searchTerm: String = "" {
        didSet {
            currentTask?.cancel()
            currentTask = Task {
                let term = self.searchTerm.isEmpty ? "a" : self.searchTerm
                let value = await self.conjugationStorage.filter(with: term)
                do {
                    try Task.checkCancellation()
                } catch {
                    return
                }
                DispatchQueue.main.async {
                    self.displayedConjugations = value
                    self.currentTask = nil
                }
            }
        }
    }

    private var conjugationStorage: FastTermSearchStorage<Conjugation> = .init(array: [], stringKeypath: \.infinitive)
    @Saved("conjugations") private var savedConjugations: [Conjugation] = []
    
    private var currentTask: Task<(), Never>?
        
    init() {
        if savedConjugations.isEmpty {
            let decodedConjugations = Bundle.main.url(forResource: "french-verb-conjugation", withExtension: "csv")
                .flatMap { try? String(data: .init(contentsOf: $0), encoding: .utf8) }
                .map { $0.split(separator: "\n").dropFirst() }
                .map { strings in
                    strings.compactMap {
                        Conjugation(strings: Array($0.split(separator: ","))
                            .map { String($0).replacingOccurrences(of: ";", with: " / ") })
                    }
                } ?? []

            self.savedConjugations = decodedConjugations.uniqueValues { $0.infinitive == $1.infinitive }
        }
        conjugationStorage = .init(array: savedConjugations, stringKeypath: \.infinitive)
        displayedConjugations = savedConjugations
    }
    
}

extension Array {
    
    func filter(isIncluded: @escaping (Element) -> Bool) async -> Self {
        await withCheckedContinuation { continuation in
            DispatchQueue(label: "searchQueue").async {
                continuation.resume(with: .success(self.filter(isIncluded)))
            }
        }
    }
}

struct Conjugation: Hashable, Identifiable, Codable {
    
    var id: String { infinitive }
    
    let infinitive: String
    let gerund: String
    let presentParticiple: String
    let pastParticiple: String
    let compoundVerb: String
    
    let present: Tense
    let imperfect: Tense
    let pastHistoric: Tense
    let future: Tense
    let conditional: Tense
    let subjonctivePresent: Tense
    let subjonctiveImperfect: Tense
    let imperative: Tense
    
    init?(strings: [String]) {
        guard strings.count == 50 else { return nil }
        infinitive = strings[0]
        gerund = strings[1]
        presentParticiple = strings[2]
        pastParticiple = strings[3]
        compoundVerb = strings[4]
        
        present = .init(conjugations: Array(strings[5...10]))
        imperfect = .init(conjugations: Array(strings[11...16]))
        pastHistoric = .init(conjugations: Array(strings[17...22]))
        future = .init(conjugations: Array(strings[23...28]))
        conditional = .init(conjugations: Array(strings[29...34]))
        subjonctivePresent = .init(conjugations: Array(strings[35...40]))
        subjonctiveImperfect = .init(conjugations: Array(strings[41...46]))
        imperative = .init(conjugations: Array(strings[47...49]))
    }
}

struct Tense: Hashable, Codable {
    let conjugations: [String]
}
