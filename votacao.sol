// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Votacao {
    address public responsavel;
    bool public votacaoAberta;
    
    struct Candidato {
        uint id;
        string nome;
        uint qtdVotos;
    }
    
    struct Eleitor {
        bool registrado;
        bool votou;
    }
    
    mapping(address => Eleitor) public eleitores;
    mapping(uint => Candidato) public candidatos;
    // pra permitir votar por nome
    mapping(string => uint) private idCandidatos;
    uint public qtdCandidatos;

    constructor() {
        responsavel = msg.sender;
        votacaoAberta = true;
    }

    modifier apenasResponsavel() {
        require(msg.sender == responsavel, "Apenas o responsavel pela votacao pode realizar esta acao.");
        _;
    }

    modifier apenasEleitorRegistrado() {
        require(eleitores[msg.sender].registrado, "Voce nao esta registrado para votar.");
        _;
    }
    
    function registrarCandidato(string memory _nome) public apenasResponsavel {
        qtdCandidatos++;
        candidatos[qtdCandidatos] = Candidato(qtdCandidatos, _nome, 0);
        // mapeia o nome para o id
        idCandidatos[_nome] = qtdCandidatos;
    }

    function registrarEleitor(address _eleitor) public apenasResponsavel {
        eleitores[_eleitor].registrado = true;
    }

    function votarPorId(uint _idCandidato) public apenasEleitorRegistrado {
        require(!eleitores[msg.sender].votou, "Voce ja votou.");
        require(votacaoAberta, "A votacao esta fechada.");
        require(_idCandidato > 0 && _idCandidato <= qtdCandidatos, "Candidato invalido.");

        eleitores[msg.sender].votou = true;
        candidatos[_idCandidato].qtdVotos++;
    }

    function votarPorNome(string memory _nomeCandidato) public apenasEleitorRegistrado {
        uint id = idCandidatos[_nomeCandidato];
        require(id > 0 && id <= qtdCandidatos, "Candidato invalido.");

        votarPorId(id);
    }

    function finalizarVotacao() public apenasResponsavel {
        votacaoAberta = false;
    }

    function resultados() public view returns (uint[] memory, string[] memory, uint[] memory) {
        uint[] memory ids = new uint[](qtdCandidatos);
        string[] memory nomes = new string[](qtdCandidatos);
        uint[] memory qtdsVotos = new uint[](qtdCandidatos);

        for (uint i = 1; i <= qtdCandidatos; i++) {
            ids[i - 1] = candidatos[i].id;
            nomes[i - 1] = candidatos[i].nome;
            qtdsVotos[i - 1] = candidatos[i].qtdVotos;
        }

        return (ids, nomes, qtdsVotos);
    }
}
