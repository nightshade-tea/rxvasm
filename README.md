# rxvasm

assembler para a arquitetura reduxv

## dependências

- `perl >= 5.32.0`

## uso

`perl rxvasm.pl programa.s saida.bin`

ou

`./rxvasm.pl programa.s saida.bin`

## diretivas

por enquanto, o assembler tem suporte às diretivas `.bits8` e `.space` do emulador [egg](https://github.com/gboncoffee/egg).

## extensões da isa

novas instruções podem ser adicionadas modificando a hash `%instructions` em `lib/rxvdef.pl`.
