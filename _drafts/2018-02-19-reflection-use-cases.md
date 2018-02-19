Topics

1. Introduction
2. What is Reflection
3. Reflection under the hood
4. Usage cases
5. Conclusion

Swift is used to be thought as statically typed language. At the same time, it allows to harness meta data about the type system and other entries that were in the program at runtime. This opens ability for many dynamic features, such as looking at the types and the methods and other objects that we defined in our code and build higher abstractions on top of that. This technique is called Reflection. In this article we will have an in-depth look into Reflection implementation in Swift as well as discuss useful usage scenarios for your production code.å


Swift is considered to be a statically typed language. However, there is a secret double life to Swift’s type system at runtime that allows to harness meta data about the type system and other entries that were in the program. The technique that uses such metadata to write code about our code is called Reflection. 

# What is Reflection