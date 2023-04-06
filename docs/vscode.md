# VSCODE ROLE

## What it does

* Installs vscode extensions
* Installs vscode themes
* Installs vscode snippets
* Setsup vscode  profile

## How To Use

```bash
$ make vscode
```

Is also run automatically by `make setup`

By default runs on all targets, example run below shows role executing on both mac target (kelso.localhost) and debian target (rhyl.io37.ch)

## Example run

```bash
 make vscode
$(python3 -m site --user-base)/bin/ansible-playbook setup.yml -i hosts --tags "vscode"

PLAY [Before everything] **************************************************************************************************************


TASK [vscode : install VSCode packages] ***********************************************************************************************
changed: [kelso.localhost] => (item=astro-build.astro-vscode)
changed: [kelso.localhost] => (item=GitHub.copilot)
changed: [kelso.localhost] => (item=styled-components.vscode-styled-components)
changed: [kelso.localhost] => (item=abalejr.forest-focus)
changed: [kelso.localhost] => (item=aregghazaryan.glass-ui)
changed: [kelso.localhost] => (item=dbaeumer.vscode-eslint)
changed: [kelso.localhost] => (item=gerane.Theme-zombiesatemyneighbors)
changed: [kelso.localhost] => (item=jmsv.JavaScriptSnippetsStandard)
changed: [kelso.localhost] => (item=tinkertrain.theme-panda)
changed: [kelso.localhost] => (item=johnpapa.vscode-peacock)
changed: [kelso.localhost] => (item=juhakokkonen.py-light)
changed: [kelso.localhost] => (item=karunamurti.haml)
changed: [kelso.localhost] => (item=unifiedjs.vscode-mdx)
changed: [kelso.localhost] => (item=github.github-vscode-theme)
changed: [kelso.localhost] => (item=lintangwisesa.arduino)
changed: [kelso.localhost] => (item=lninl.theme-hbuilderx-soft-green-light)
changed: [kelso.localhost] => (item=luqimin.tiny-light)
changed: [kelso.localhost] => (item=misogi.ruby-rubocop)
changed: [kelso.localhost] => (item=raashida.fixthecode-vs)
changed: [kelso.localhost] => (item=rebornix.ruby)
changed: [kelso.localhost] => (item=selfrefactor.zeppelin-themes)
changed: [kelso.localhost] => (item=sveggiani.vscode-field-lights)
changed: [kelso.localhost] => (item=syler.sass-indented)
changed: [kelso.localhost] => (item=taniarascia.new-moon-vscode)
changed: [kelso.localhost] => (item=teabyii.ayu)
changed: [kelso.localhost] => (item=tristanremy.mirage)
changed: [kelso.localhost] => (item=wingrunr21.vscode-ruby)
changed: [kelso.localhost] => (item=wraith13.unsaved-files-vscode)
changed: [kelso.localhost] => (item=aaron-bond.better-comments)
changed: [kelso.localhost] => (item=eamodio.gitlens)
changed: [kelso.localhost] => (item=dbaeumer.vscode-eslint)
changed: [kelso.localhost] => (item=dart-code.dart-code)
changed: [kelso.localhost] => (item=dart-code.flutter)
changed: [kelso.localhost] => (item=ms-vscode.vscode-typescript-tslint-plugin)
changed: [kelso.localhost] => (item=ChakrounAnas.turbo-console-log)
changed: [kelso.localhost] => (item=humao.rest-client)
changed: [kelso.localhost] => (item=wholroyd.jinja)

TASK [vscode : copy vscode profile] ***************************************************************************************************
ok: [kelso.localhost]

TASK [vscode : Create snippets directory] *********************************************************************************************
ok: [kelso.localhost]

TASK [vscode : Copy snippets] *********************************************************************************************************
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/html.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/readmore.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/nextstaticprops.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/readme.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/next-with-component.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/component.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/link.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/debug_css.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/linx.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/orange.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/purple.code-snippets)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/snippets/next-page.code-snippets)

TASK [vscode : Create themes directory] ***********************************************************************************************
ok: [kelso.localhost]

TASK [vscode : Copy themes] ***********************************************************************************************************
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/themes/panda.json)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/themes/green.json)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/themes/blue.json)
ok: [kelso.localhost] => (item=/Users/brew/macfair/files/themes/pink.json)

PLAY RECAP ****************************************************************************************************************************
kelso.localhost            : ok=24   changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
