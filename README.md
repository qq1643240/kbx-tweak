# super X

An iOS keyboard tweak: send selected text / images to an LLM from the keyboard,
with a floating result popup, token selection, screenshot overlay and a
preference panel.

## Build

```bash
export THEOS=~/theos
export PATH=$THEOS/bin:$PATH
make clean package THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1
make clean package THEOS_PACKAGE_SCHEME=roothide FINALPACKAGE=1
```

Artifacts land in `packages/`.
