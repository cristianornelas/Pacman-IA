% 0 - Nada
% 1 - Pacman
% 2 - Monstro
% 3 - Fruta

%Roda o jogo
play(Objetivo, Fronteira):-bl(Objetivo, [], Fronteira).

%Faz a busca em largura para pegar o caminho de X até Y
bl(Final, _, [[Final|Caminho]|_]):-getUltimo([Final|Caminho], Inicial), getEstadoFruta(Inicial, FrutaEstado), pertenceLista(FrutaEstado, [Final|Caminho]), write([Final|Caminho]), nl.
bl(Final, E, [[N|Caminho]|TailF]):-getUltimo([N|Caminho], Inicial), getEstadoFruta(Inicial, FrutaEstado), inserir(N, E, NewE), bagof(Y, move(pertenceLista(FrutaEstado, [N|Caminho]), N, Y), Sucessores), disjuncao(Sucessores, NewE, TailF, NewSucessores), concSufixo(NewSucessores, [N|Caminho], SucessoresCaminhos), concatena(TailF, SucessoresCaminhos, RealNewF), bl(Final, NewE, RealNewF), !.

%Verifica se um elemento pertence à uma lista
pertenceLista(Elem, [Elem|_]).
pertenceLista(Elem, [_|Tail]):-pertenceLista(Elem, Tail).

%Retorna o ultimo elemento de uma lista
getUltimo([Elem], Elem).
getUltimo([_|Tail], Y):-getUltimo(Tail, Y).

%Encontra o indice de um elemento em uma lista
indice(Elem, [Elem|_], 1).
indice(Elem, [_|Tail], NY):- indice(Elem, Tail, Y), NY is Y + 1.

%Substitui a primeira ocorrência do elemento na lista
substitui(Origem, Target, [Origem|Tail], [Target|Tail]).
substitui(Origem, Target, [Head|Tail], [Head|NewTail]):-substitui(Origem, Target, Tail, NewTail).

%Substitui o elemento em dado indice se o elem antigo é 0
substituiIndex(Elem, Dest, 1, [Dest|Tail], [Elem|Tail]).
substituiIndex(Elem, Dest, Indice, [Head|Tail], [Head|NewTail]):- NewIndice is Indice - 1, substituiIndex(Elem,Dest, NewIndice, Tail, NewTail).

%Move para a direita
moveDir(Elem, Dest, [[Elem, Dest|Tail]|Resto], [[0, Elem|Tail]|Resto]).
moveDir(Elem, Dest, [[Head|Tail]|Resto], [[Head|L1]|Y]):-moveDir(Elem, Dest, [Tail|Resto], [L1|Y]).
moveDir(Elem, Dest, [[]|Resto], [[]|Y]):-moveDir(Elem, Dest, Resto, Y).

%Move para a esquerda
moveEsq(Elem, Dest, [[Dest, Elem|Tail]|Resto], [[Elem, 0|Tail]|Resto]).
moveEsq(Elem, Dest, [[Head|Tail]|Resto], [[Head|L1]|Y]):-moveEsq(Elem, Dest, [Tail|Resto], [L1|Y]).
moveEsq(Elem, Dest, [[]|Resto], [[]|Y]):-moveEsq(Elem, Dest, Resto, Y).

%Move para baixo
moveBaixo(Elem, Dest, [L1, L2|Resto], [NewL1, NewL2|Resto]):-indice(Elem, L1, Index), substitui(Elem, 0, L1, NewL1), substituiIndex(Elem, Dest, Index, L2, NewL2).
moveBaixo(Elem, Dest, [L1|Resto], [L1|Y]):-moveBaixo(Elem, Dest, Resto, Y).

%Move para cima
moveCima(Elem, Dest, [L1, L2|Resto], [NewL1, NewL2|Resto]):-indice(Elem, L2, Index), substitui(Elem, 0, L2,NewL2), substituiIndex(Elem, Dest, Index, L1, NewL1).
moveCima(Elem, Dest, [L1|Resto], [L1|Y]):-moveCima(Elem, Dest, Resto, Y).

%Move para a primeira direção vazia que conseguir
movePacman(Elem, X, Y):-moveDir(Elem, 0, X, Y); moveBaixo(Elem, 0, X, Y); moveEsq(Elem, 0, X, Y); moveCima(Elem, 0, X, Y).

%Move para a posição da fruta
moveFruta(Elem, X, Y):-moveDir(Elem, 3, X, Y); moveBaixo(Elem, 3, X, Y); moveEsq(Elem, 3, X, Y); moveCima(Elem, 3, X, Y).

%Move para a direção de um monstro
comeMonstro(Elem, X, Y):-moveDir(Elem, 2, X, Y); moveBaixo(Elem, 2, X, Y); moveEsq(Elem, 2, X, Y); moveCima(Elem, 2, X, Y).

%Move o pacman normal
%moveNormal(X, Y):-moveObjetivo(1, X, Y),!.
moveNormal(X, Y):-moveFruta(1, X, Y),!.
moveNormal(X, Y):-movePacman(1, X, Y).

%Move o pacman buffado
moveBuffado(X, Y):-comeMonstro(1, X, Y),!.
%moveBuffado(X, Y):-moveObjetivo(1, X, Y),!.
moveBuffado(X, Y):-movePacman(1, X, Y).

%Move o pacman
move(Buff, X, Y):-not(Buff), moveNormal(X, Y).
move(Buff, X, Y):-Buff, moveBuffado(X, Y).

%Remove elemento de uma lista
remove(Elem, [Elem|Tail], Tail).
remove(Elem, [Head|Tail], [Head|NewTail]):-remove(Elem, Tail, NewTail).

%Insere elemento no fim de uma lista
inserir(Elem, [], [Elem]).
inserir(Elem, [Head|Tail], [Head|NewTail]):-inserir(Elem, Tail, NewTail).

%Expande uma lista de elementos em uma lista de listas com esse elemento
expande([Elem], [[Elem]]).
expande([H|T], [[H]|NT]):-expande(T, NT).

%Concatena duas listas
concatena([], Elem, Elem).
concatena([H1|T1],L2,[H1|T3]):-concatena(T1, L2, T3).

%Concatena um sufixo pra cada elemento de uma lista
concSufixo([], _, []).
concSufixo([Elem], L, [[Elem|L]]).
concSufixo([H|T], L, [[H|L]|NT]):-concSufixo(T, L, NT).

%Verifica se um elemento é cabeça das listas da lista passada
eCabeca(Elem, [[Elem|_]|_]).
eCabeca(Elem, [[_|_]|Resto]):-eCabeca(Elem, Resto).

%Retorna os elementos de uma lista que não estão nas outras listas
disjuncao([], _, _, []).
disjuncao([H1|T1], L2, L3, [H1|T4]):-not(pertenceLista(H1, L2)), not(eCabeca(H1, L3)), disjuncao(T1, L2, L3, T4).
disjuncao([H1|T1], L2, L3, T4):-(pertenceLista(H1, L2); eCabeca(H1, L3)), disjuncao(T1, L2, L3, T4). %Só assim parou de retornar um monte de coisa

%Retorna o estado em que o pacman passaria pela fruta
getEstadoFruta([], []).
getEstadoFruta([[3|T1]|Resto], [[1|NT1]|NResto]):-getEstadoFruta([T1|Resto],[NT1|NResto]).
getEstadoFruta([[1|T1]|Resto], [[0|NT1]|NResto]):-getEstadoFruta([T1|Resto],[NT1|NResto]).
getEstadoFruta([[H1|T1]|Resto], [[H1|NT1]|NResto]):-H1 \== 3, getEstadoFruta([T1|Resto], [NT1|NResto]).
getEstadoFruta([[]|Resto], [[]|NResto]):-getEstadoFruta(Resto, NResto).

%Imprime o estado em formato de matriz
escreve([Elem]):-write(Elem), nl.
escreve([Head|Tail]):-write(Head), nl, escreve(Tail).

%Move para sudeste
%moveSE(Elem, [[Elem|T1], [H, 0|T2]|Resto], [[0|T1], [H, Elem|T2]|Resto]).
%moveSE(Elem, [[H1|T1], [H2a, H2b|T2]|Resto], [[H1|NT1],[H2a|NT2]|Resto]):-moveSE(Elem, [T1, [H2b|T2]|Resto], [NT1, NT2|Resto]).
%moveSE(Elem, [[H], L2|Resto], [[H]|NEstado]):-moveSE(Elem, [L2|Resto], NEstado).