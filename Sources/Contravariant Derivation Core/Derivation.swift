public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of structure: StructDeclSyntax) -> [DeclSyntax] {
        guard
            let generic = structure.genericParameterClause,
            generic.parameters.count == 1,
            let input = generic.parameters.first?.name.text
        else { return [] }

        let functions = structure.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .flatMap(\.bindings)
            .compactMap { binding -> String? in
                guard
                    let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                    let function = binding.typeAnnotation?.type.as(FunctionTypeSyntax.self),
                    function.parameters.count == 1,
                    function.parameters.first?.type.trimmedDescription == input
                else { return nil }
                return name
            }

        guard functions.count == 1 else { return [] }
        let function = functions[0]

        return ["""
            func contramap<Mapped>(_ transform: @escaping (Mapped) -> \(raw: input))
                -> \(raw: structure.name.text)<Mapped>
            {
                \(raw: structure.name.text)<Mapped>(
                    \(raw: function): { self.\(raw: function)(transform($0)) }
                )
            }
            """]
    }
}
