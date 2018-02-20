Topics

1. Introduction
2. What is Reflection
3. Reflection under the hood
4. Usage cases
5. Conclusion

Although Swift is a statically typed language, there is a secret double life to Swift’s type system at runtime that paves the way to some dynamism. This allows to look at the types and the methods that we defined in our code and build higher abstractions on top of that. This technique is called Reflection. In this article we will have a look at Reflection and Mirror type as well as discuss several practical usage scenarios.

# Reflection and Mirror

Reflection is [defined][reflection-def] as the ability of a computer program to examine, introspect, and modify its own structure and behavior at runtime.

[Introspection][introspection-def], in turn, is the ability of a program to examine the type or properties of an object at runtime.

Swift's Reflection is limited, providing read-only access to a subset of type metadata. Such metadata is encapsulated in `Mirror` instances.

# Reflection in-depth

1. Mirrored object is boxed into MagicMirror instance. It buffers object using calling it's [witness table][witness-table-def]
2. Class's 

MagicMirror is a mirror box.

 


[reflection-def]: https://en.wikipedia.org/wiki/Reflection_(computer_programming)
[introspection-def]: https://en.wikipedia.org/wiki/Type_introspection
[witness-table-def]: https://github.com/apple/swift/blob/master/docs/SIL.rst#witness-tables