import 'dart:math';

import 'package:flutter/material.dart';

class JogoDaVelha extends StatefulWidget {
  const JogoDaVelha({super.key});

  @override
  State<JogoDaVelha> createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> _tabuleiro = List.filled(9, ''); // Tabuleiro do jogo
  String _jogador = 'X'; // Jogador atual (X ou O)
  bool _contraMaquina = false; // Jogando contra a máquina?
  final Random _randomico = Random(); // Gerador de números aleatórios
  bool _pensando = false; // A máquina está pensando na jogada?

  // Inicia um novo jogo
  void _iniciarJogo() {
    setState(() {
      _tabuleiro = List.filled(9, ''); // Limpa o tabuleiro
      _jogador = 'X'; // Define o jogador inicial como X
    });
  }

  // Troca o jogador atual
  void _trocaJogador() {
    setState(() {
      _jogador = _jogador == 'X' ? 'O' : 'X';
    });
  }

  // Mostra um diálogo com o resultado do jogo
  void _mostreDialogoVencedor(String vencedor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vencedor == 'Empate' ? 'Empate!' : 'Vencedor: $vencedor'),
          actions: [
            ElevatedButton(
              child: const Text('Reiniciar Jogo'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                _iniciarJogo(); // Inicia um novo jogo
              },
            ),
          ],
        );
      },
    );
  }

  // Verifica se há um vencedor ou se o jogo empatou
  bool _verificaVencedor(String jogador) {
    // Define as combinações de posições vencedoras
    const posicoesVencedoras = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    // Verifica se o jogador atual venceu em alguma das combinações
    for (var posicoes in posicoesVencedoras) {
      if (_tabuleiro[posicoes[0]] == jogador &&
          _tabuleiro[posicoes[1]] == jogador &&
          _tabuleiro[posicoes[2]] == jogador) {
        _mostreDialogoVencedor(jogador); // Mostra o diálogo de vencedor
        return true;
      }
    }

    // Verifica se houve empate
    if (!_tabuleiro.contains('')) {
      _mostreDialogoVencedor('Empate'); // Mostra o diálogo de empate
      return true;
    }

    return false; // Nenhum vencedor ainda
  }

  // Realiza a jogada do computador
  void _jogadaComputador() {
    setState(() => _pensando = true); // Mostra indicador de "pensando"

    // Simula um tempo de "pensamento"
    Future.delayed(const Duration(seconds: 1), () {
      int movimento;
      do {
        movimento = _randomico.nextInt(9); // Escolhe uma posição aleatória
      } while (_tabuleiro[movimento] != ''); // Repete até encontrar uma posição vazia

      setState(() {
        _tabuleiro[movimento] = 'O'; // Faz a jogada
        if (!_verificaVencedor(_jogador)) {
          _trocaJogador(); // Troca para o jogador humano
        }
        _pensando = false; // Esconde o indicador de "pensando"
      });
    });
  }

  // Realiza a jogada do jogador humano
  void _jogada(int index) {
    if (_tabuleiro[index] == '') {
      // Verifica se a posição está vazia
      setState(() {
        _tabuleiro[index] = _jogador; // Faz a jogada
        if (!_verificaVencedor(_jogador)) {
          _trocaJogador(); // Troca para o próximo jogador
          if (_contraMaquina && _jogador == 'O') {
            _jogadaComputador(); // Se estiver jogando contra a máquina, faz a jogada do computador
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double altura = MediaQuery.of(context).size.height * 0.5; // Calcula a altura do tabuleiro
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: _contraMaquina,
                  onChanged: (value) {
                    setState(() {
                      _contraMaquina = value; // Alterna entre jogar contra a máquina ou humano
                      _iniciarJogo(); // Reinicia o jogo
                    });
                  },
                ),
              ),
              Text(_contraMaquina ? 'Computador' : 'Humano'), // Mostra o modo de jogo
              const SizedBox(width: 30.0),
              if (_pensando) // Mostra o indicador de "pensando" se a máquina estiver jogando
                const SizedBox(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: SizedBox(
            width: altura,
            height: altura,
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _jogada(index), // Chama a função _jogada ao tocar em uma célula
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        _tabuleiro[index], // Mostra o X ou O na célula
                        style: const TextStyle(fontSize: 40.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: _iniciarJogo, // Reinicia o jogo ao pressionar o botão
            child: const Text('Reiniciar Jogo'),
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}