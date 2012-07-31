Cocolize is an attempt at reducing translation workload on multi platform development. It allows iOS developers to link directly into Android string files to centralize the translated texts. This means instead of having strings.xml for your Android development and then copying all those strings over manually (or worse, sending the copied strings to translate as well), you can now automatically generate the iOS Localizable.strings file or use the strings.xml file directly.

There are two variants

cocolize
========

cocolize is a command line tool that uses the following syntax to manually convert from an Android xml file to an iOS strings file.

    cocolize --in strings.xml --out Localizable.strings

This tool can be used as a Xcode build script if needed.

libCocolize
===========

On the other hand libCocolize, is an attempt at using Android xml files directly in an iOS project. The library overrides NSLocalizedString to use the localized xml file of your choice. 

An example of how to use it:

    NSString* helloWorld = NSLocalizedString(@"hello world", @"");
    NSString* lang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex: 0];
    NSLog(@"Hello world in (%@) is: %@", lang, helloWorld);

will output:

    Hello world in (en) is: Hello World
    Hello world in (fr) is: Bonjour monde

The project can be installed as a normal dependency but make sure the -ObjC, -all_load linker flags are defined or the category will not load correctly.

The minimum requirements for libCocolize are:
<ul>
<li>Xcode 4.4</li>
<li>iOS 4.0+</li>
</ul>
