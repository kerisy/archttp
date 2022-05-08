module main;

import nbuff;

import std.stdio;
import std.algorithm : copy;

void main()
{
    import std.string;
    import std.stdio;
    Nbuff b;
    auto d = b;
    auto chunk = Nbuff.get(512);
    copy("Abc".representation, chunk.data);
    b.append(chunk, 3);
    chunk = Nbuff.get(16);
    copy("Def".representation, chunk.data);
    b.append(chunk, 3);
    d = b;

    writeln(chunk.data);
}
