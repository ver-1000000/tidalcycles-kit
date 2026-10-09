# Third-party software

The kit's own code is MIT-licensed; see LICENSE. This does not relicense third-party components.

- Tidal 1.10.3: GPL-3.0, obtained from Hackage
- Tidal's transitive dependencies: their respective package licenses
- Haskell base image, GHC, Cabal, and OS packages: their respective upstream licenses
- SuperDirt, Vowel, and Dirt-Samples: fetched from pinned upstream revisions inside runtime/Containerfile.audio; upstream license files remain in the image checkouts
- SuperCollider, PipeWire client libraries and Debian audio dependencies: installed inside the audio image; their respective upstream licenses apply
- SC3 plugins: installed inside the audio image from Debian; upstream licenses and notices are retained in the Debian packages

Downloaded Hackage package source archives are retained in `/opt/tidal/sources`. GHC's compressed upstream documentation, including notices, is retained in `/opt/ghc/9.6.7/share/doc/ghc-9.6.7/archives`. Audio dependency sources and their license files are retained in `/opt/quarks`. Distribution of container images must comply with the licenses of all included components, including applicable notice and corresponding-source requirements.
