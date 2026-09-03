import Contravariant_Derivation
import Testing

@Contravariant
private struct Predicate<Input> {
    var evaluate: (Input) -> Bool
}

@Test
func `derived contramap composes input transformations`() {
    let positive = Predicate<Int> { $0 > 0 }
    let nonempty = positive.contramap { (text: String) in text.count }

    #expect(nonempty.evaluate("Blob"))
    #expect(!nonempty.evaluate(""))
}
