CREATE DATABASE powerhome;
USE powerhome;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT ck_usuario_ativo CHECK (ativo IN (0, 1))
);

CREATE TABLE comodo (
    id_comodo INT AUTO_INCREMENT,
    nome_comodo VARCHAR(50) NOT NULL,
    icone VARCHAR(50),
    fk_usuario_id INT NOT NULL,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_comodo PRIMARY KEY (id_comodo),
    CONSTRAINT fk_comodo_usuario FOREIGN KEY (fk_usuario_id) 
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_comodo_ativo CHECK (ativo IN (0, 1))
);

CREATE TABLE status_conexao (
    id_status INT AUTO_INCREMENT,
    descricao VARCHAR(20) NOT NULL UNIQUE,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_status PRIMARY KEY (id_status),
    CONSTRAINT ck_status_ativo CHECK (ativo IN (0, 1))
);

CREATE TABLE dispositivo (
    id_dispositivo INT AUTO_INCREMENT,
    nome_dispositivo VARCHAR(50) NOT NULL,
    endereco_mac VARCHAR(17) NOT NULL UNIQUE,
    icone VARCHAR(50) NOT NULL,
    potencia_nominal INT NOT NULL,
    estado_atual TINYINT(1) NOT NULL DEFAULT 0,
    fk_usuario_id INT NOT NULL,
    fk_comodo_id INT NOT NULL,
    fk_status_id INT NOT NULL,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_dispositivo PRIMARY KEY (id_dispositivo),
    CONSTRAINT fk_dispositivo_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_dispositivo_comodo FOREIGN KEY (fk_comodo_id) REFERENCES comodo(id_comodo) ON UPDATE CASCADE,
    CONSTRAINT fk_dispositivo_status FOREIGN KEY (fk_status_id) REFERENCES status_conexao(id_status) ON UPDATE CASCADE,
    CONSTRAINT ck_dispositivo_ativo CHECK (ativo IN (0, 1)),
    CONSTRAINT ck_dispositivo_potencia CHECK (potencia_nominal > 0)
);

CREATE TABLE leitura_consumo (
    id_leitura BIGINT AUTO_INCREMENT,
    valor_watts DECIMAL(10,2) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fk_dispositivo_id INT NOT NULL,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_leitura PRIMARY KEY (id_leitura),
    CONSTRAINT fk_leitura_dispositivo FOREIGN KEY (fk_dispositivo_id) REFERENCES dispositivo(id_dispositivo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_leitura_ativo CHECK (ativo IN (0, 1)),
    CONSTRAINT ck_leitura_positiva CHECK (valor_watts >= 0)
);

CREATE TABLE notificacao (
    id_alerta INT AUTO_INCREMENT,
    titulo VARCHAR(50) NOT NULL,
    mensagem VARCHAR(255) NOT NULL,
    lida TINYINT(1) NOT NULL DEFAULT 0,
    data_envio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fk_dispositivo_id INT NOT NULL,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_notificacao PRIMARY KEY (id_alerta),
    CONSTRAINT fk_notificacao_dispositivo FOREIGN KEY (fk_dispositivo_id) REFERENCES dispositivo(id_dispositivo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_notificacao_ativo CHECK (ativo IN (0, 1))
);

CREATE TABLE automacao (
    id_automacao INT AUTO_INCREMENT,
    acao VARCHAR(10) NOT NULL,
    horario TIME NOT NULL,
    frequencia VARCHAR(20) NOT NULL,
    fk_dispositivo_id INT NOT NULL,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_automacao PRIMARY KEY (id_automacao),
    CONSTRAINT fk_automacao_dispositivo FOREIGN KEY (fk_dispositivo_id) REFERENCES dispositivo(id_dispositivo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_automacao_ativo CHECK (ativo IN (0, 1))
);

CREATE TABLE data_alvo (
    id_data INT AUTO_INCREMENT,
    nome_dia VARCHAR(15),
    data_especifica DATE,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_data_alvo PRIMARY KEY (id_data),
    CONSTRAINT ck_data_ativo CHECK (ativo IN (0, 1))
);

CREATE TABLE agendamento (
    fk_automacao_id INT NOT NULL,
    fk_data_alvo_id INT NOT NULL,
    ativo INT DEFAULT 1,
    CONSTRAINT pk_agendamento PRIMARY KEY (fk_automacao_id, fk_data_alvo_id),
    CONSTRAINT fk_agendamento_automacao FOREIGN KEY (fk_automacao_id) REFERENCES automacao(id_automacao) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_agendamento_data FOREIGN KEY (fk_data_alvo_id) REFERENCES data_alvo(id_data) ON UPDATE CASCADE,
    CONSTRAINT ck_agendamento_ativo CHECK (ativo IN (0, 1))
);

SHOW TABLES;
DESCRIBE dispositivo;
DESCRIBE comodo;
DESCRIBE status_conexao;
DESCRIBE dispositivo;
DESCRIBE leitura_consumo;
DESCRIBE notificacao;
DESCRIBE automacao;
DESCRIBE data_alvo;
DESCRIBE agendamento;

INSERT INTO usuario (nome, email, senha) VALUES
('Rafael Bueno', 'rafael@powerhome.com', 'hash123'), ('Milena Kaori', 'milena@powerhome.com', 'hash123'),
('Victor Siquetto', 'victor@powerhome.com', 'hash123'), ('Nicolas Pontes', 'nicolas@powerhome.com', 'hash123'),
('Arthur Barros', 'arthur@powerhome.com', 'hash123'), ('João Silva', 'joao@email.com', 'senha456'),
('Maria Oliveira', 'maria@email.com', 'senha789'), ('Carlos Souza', 'carlos@email.com', 'senha321'),
('Ana Pereira', 'ana@email.com', 'senha654'), ('Lucas Lima', 'lucas@email.com', 'senha987');

INSERT INTO comodo (nome_comodo, icone, fk_usuario_id) VALUES
('Sala de Estar', 'fa-couch', 1), ('Quarto Principal', 'fa-bed', 1), ('Cozinha', 'fa-utensils', 1),          
('Escritório', 'fa-laptop', 2), ('Sala de Jantar', 'fa-utensils', 2), ('Garagem', 'fa-car', 3),               
('Jardim', 'fa-leaf', 3), ('Varanda', 'fa-sun', 4), ('Quarto Hóspedes', 'fa-bed', 5), ('Banheiro Social', 'fa-bath', 5);      

INSERT INTO status_conexao (descricao) VALUES 
('Online'), ('Offline'), ('Erro'), ('Sincronizando'), ('Em Manutenção'), 
('Atualizando'), ('Bateria Fraca'), ('Pareando'), ('Desabilitado'), ('Desconhecido');

INSERT INTO dispositivo (nome_dispositivo, endereco_mac, icone, potencia_nominal, estado_atual, fk_usuario_id, fk_comodo_id, fk_status_id) VALUES
('TV da Sala', 'AA:BB:CC:00:01', 'fa-tv', 150, 1, 1, 1, 1), ('Ar Condicionado', 'AA:BB:CC:00:02', 'fa-wind', 2200, 0, 1, 2, 2),
('Geladeira', 'AA:BB:CC:00:03', 'fa-plug', 300, 1, 1, 3, 1), ('Lâmpada Escritório', 'AA:BB:CC:00:04', 'fa-lightbulb', 15, 1, 2, 4, 1), 
('Cafeteira', 'AA:BB:CC:00:05', 'fa-coffee', 800, 0, 2, 5, 1), ('Portão Eletrônico', 'AA:BB:CC:00:06', 'fa-dungeon', 50, 1, 3, 6, 1), 
('Cortina Smart', 'AA:BB:CC:00:07', 'fa-blinds', 30, 0, 3, 7, 3), ('Câmera Varanda', 'AA:BB:CC:00:08', 'fa-video', 10, 1, 4, 8, 1),    
('Ventilador', 'AA:BB:CC:00:09', 'fa-fan', 60, 0, 5, 9, 1), ('Aquecedor', 'AA:BB:CC:00:10', 'fa-fire', 1500, 1, 5, 10, 4);       

INSERT INTO leitura_consumo (valor_watts, data_hora, fk_dispositivo_id) VALUES
(145.50, '2025-11-28 10:00:00', 1), (148.20, '2025-11-28 10:05:00', 1), (290.00, '2025-11-28 10:00:00', 3), 
(305.10, '2025-11-28 11:00:00', 3), (15.00,  '2025-11-28 18:00:00', 4), (15.00,  '2025-11-28 19:00:00', 4),
(800.00, '2025-11-28 08:00:00', 5), (50.00,  '2025-11-28 12:30:00', 6), (10.00,  '2025-11-28 00:00:00', 8), 
(1500.0, '2025-11-28 22:00:00', 10);

INSERT INTO notificacao (titulo, mensagem, lida, fk_dispositivo_id) VALUES
('Consumo Alto', 'A TV consumiu acima da média.', 0, 1), ('Dispositivo Offline', 'O Ar Condicionado perdeu conexão.', 0, 2),
('Porta Aberta', 'A Geladeira ficou aberta por muito tempo.', 1, 3), ('Lâmpada Ligada', 'Lâmpada acessa por mais de 10h.', 0, 4),
('Café Pronto', 'Sua cafeteira terminou o ciclo.', 1, 5), ('Portão Acionado', 'O portão foi aberto manualmente.', 0, 6),
('Erro Crítico', 'Falha no motor da cortina.', 0, 7), ('Movimento Detectado', 'Câmera detectou movimento na varanda.', 1, 8),
('Temperatura Alta', 'O Aquecedor está ligado há 5 horas.', 0, 10), ('Bem-vindo', 'Novo dispositivo Ventilador configurado.', 1, 9);

INSERT INTO automacao (acao, horario, frequencia, fk_dispositivo_id) VALUES
('LIGAR', '18:00:00', 'DIARIO', 1), ('DESLIGAR','23:00:00', 'DIARIO', 1), ('LIGAR', '22:00:00', 'DIARIO', 2),      
('DESLIGAR','06:00:00', 'DIARIO', 2), ('LIGAR', '07:00:00', 'SEMANAL', 5), ('LIGAR', '18:30:00', 'DIARIO', 4),      
('DESLIGAR','22:30:00', 'DIARIO', 4), ('LIGAR', '20:00:00', 'UMA_VEZ', 10), ('DESLIGAR','08:00:00', 'DIARIO', 8),    
('LIGAR', '18:00:00', 'DIARIO', 8);      

INSERT INTO data_alvo (nome_dia, data_especifica) VALUES 
('Segunda', NULL), ('Terca', NULL), ('Quarta', NULL), ('Quinta', NULL), ('Sexta', NULL), ('Sabado', NULL), ('Domingo', NULL),
(NULL, '2025-12-25'), (NULL, '2025-12-31'), (NULL, '2025-01-01');

INSERT INTO agendamento (fk_automacao_id, fk_data_alvo_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (3, 6), (3, 7), (5, 1), (8, 8), (8, 9); 

SELECT * FROM dispositivo;
SELECT * FROM comodo;
SELECT * FROM status_conexao;
SELECT * FROM dispositivo;
SELECT * FROM leitura_consumo;
SELECT * FROM notificacao;
SELECT * FROM automacao;
SELECT * FROM data_alvo;
SELECT * FROM agendamento;

DELIMITER //
CREATE PROCEDURE sp_incluir_usuario(IN p_nome VARCHAR(100), IN p_email VARCHAR(100), IN p_senha VARCHAR(255))
BEGIN
    INSERT INTO usuario (nome, email, senha) VALUES (p_nome, p_email, p_senha);
END //
DELIMITER ;

CALL sp_incluir_usuario('Teste User', 'teste@demo.com', '123456');
SELECT * FROM usuario WHERE email = 'teste@demo.com';

DELIMITER //
CREATE PROCEDURE sp_atualizar_usuario(IN p_id INT, IN p_nome VARCHAR(100), IN p_senha VARCHAR(255))
BEGIN
    UPDATE usuario SET nome = p_nome, senha = p_senha WHERE id_usuario = p_id;
END //
DELIMITER ;

CALL sp_atualizar_usuario((SELECT MAX(id_usuario) FROM usuario), 'Teste User Alterado', '654321');
SELECT * FROM usuario WHERE email = 'teste@demo.com';

DELIMITER //
CREATE PROCEDURE sp_excluir_usuario(IN p_id INT)
BEGIN
    UPDATE usuario SET ativo = 0 WHERE id_usuario = p_id;
END //
DELIMITER ;

CALL sp_excluir_usuario((SELECT MAX(id_usuario) FROM usuario));
SELECT * FROM usuario WHERE email = 'teste@demo.com';

DELIMITER //
CREATE PROCEDURE sp_incluir_comodo(IN p_nome VARCHAR(50), IN p_icone VARCHAR(50), IN p_user_id INT)
BEGIN
    INSERT INTO comodo (nome_comodo, icone, fk_usuario_id) VALUES (p_nome, p_icone, p_user_id);
END //
DELIMITER ;

CALL sp_incluir_comodo('Teste Comodo', 'fa-box', 1);
SELECT * FROM comodo WHERE nome_comodo = 'Teste Comodo';

DELIMITER //
CREATE PROCEDURE sp_atualizar_comodo(IN p_id INT, IN p_nome VARCHAR(50), IN p_icone VARCHAR(50))
BEGIN
    UPDATE comodo SET nome_comodo = p_nome, icone = p_icone WHERE id_comodo = p_id;
END //
DELIMITER ;

CALL sp_atualizar_comodo((SELECT MAX(id_comodo) FROM comodo), 'Teste Comodo Alterado', 'fa-box-open');
SELECT * FROM comodo WHERE nome_comodo = 'Teste Comodo Alterado';

DELIMITER //
CREATE PROCEDURE sp_excluir_comodo(IN p_id INT)
BEGIN
    UPDATE comodo SET ativo = 0 WHERE id_comodo = p_id;
END //
DELIMITER ;

CALL sp_excluir_comodo((SELECT MAX(id_comodo) FROM comodo));
SELECT * FROM comodo WHERE nome_comodo = 'Teste Comodo Alterado';

DELIMITER //
CREATE PROCEDURE sp_incluir_status(IN p_desc VARCHAR(20))
BEGIN
    INSERT INTO status_conexao (descricao) VALUES (p_desc);
END //
DELIMITER ;

CALL sp_incluir_status('Teste Status');
SELECT * FROM status_conexao WHERE descricao = 'Teste Status';

DELIMITER //
CREATE PROCEDURE sp_atualizar_status(IN p_id INT, IN p_desc VARCHAR(20))
BEGIN
    UPDATE status_conexao SET descricao = p_desc WHERE id_status = p_id;
END //
DELIMITER ;

CALL sp_atualizar_status((SELECT MAX(id_status) FROM status_conexao), 'Teste Status Alt');
SELECT * FROM status_conexao WHERE descricao = 'Teste Status Alt';

DELIMITER //
CREATE PROCEDURE sp_excluir_status(IN p_id INT)
BEGIN
    UPDATE status_conexao SET ativo = 0 WHERE id_status = p_id;
END //
DELIMITER ;

CALL sp_excluir_status((SELECT MAX(id_status) FROM status_conexao));
SELECT * FROM status_conexao WHERE descricao = 'Teste Status Alt';

DELIMITER //
CREATE PROCEDURE sp_incluir_dispositivo(IN p_nome VARCHAR(50), IN p_mac VARCHAR(17), IN p_icone VARCHAR(50), IN p_potencia INT, IN p_user_id INT, IN p_comodo_id INT, IN p_status_id INT)
BEGIN
    INSERT INTO dispositivo (nome_dispositivo, endereco_mac, icone, potencia_nominal, fk_usuario_id, fk_comodo_id, fk_status_id) 
    VALUES (p_nome, p_mac, p_icone, p_potencia, p_user_id, p_comodo_id, p_status_id);
END //
DELIMITER ;

CALL sp_incluir_dispositivo('Teste Disp', 'TT:TT:TT:00:00', 'fa-test', 50, 1, 1, 1);
SELECT * FROM dispositivo WHERE endereco_mac = 'TT:TT:TT:00:00';

DELIMITER //
CREATE PROCEDURE sp_atualizar_dispositivo(IN p_id INT, IN p_nome VARCHAR(50), IN p_potencia INT)
BEGIN
    UPDATE dispositivo SET nome_dispositivo = p_nome, potencia_nominal = p_potencia WHERE id_dispositivo = p_id;
END //
DELIMITER ;

CALL sp_atualizar_dispositivo((SELECT MAX(id_dispositivo) FROM dispositivo), 'Teste Disp Alterado', 100);
SELECT * FROM dispositivo WHERE endereco_mac = 'TT:TT:TT:00:00';

DELIMITER //
CREATE PROCEDURE sp_excluir_dispositivo(IN p_id INT)
BEGIN
    UPDATE dispositivo SET ativo = 0 WHERE id_dispositivo = p_id;
END //
DELIMITER ;

CALL sp_excluir_dispositivo((SELECT MAX(id_dispositivo) FROM dispositivo));
SELECT * FROM dispositivo WHERE endereco_mac = 'TT:TT:TT:00:00';

DELIMITER //
CREATE PROCEDURE sp_incluir_leitura(IN p_valor DECIMAL(10,2), IN p_disp_id INT)
BEGIN
    INSERT INTO leitura_consumo (valor_watts, fk_dispositivo_id) VALUES (p_valor, p_disp_id);
END //
DELIMITER ;

CALL sp_incluir_leitura(99.9, 1);
SELECT * FROM leitura_consumo WHERE valor_watts = 99.9;

DELIMITER //
CREATE PROCEDURE sp_atualizar_leitura(IN p_id BIGINT, IN p_valor DECIMAL(10,2))
BEGIN
    UPDATE leitura_consumo SET valor_watts = p_valor WHERE id_leitura = p_id;
END //
DELIMITER ;

CALL sp_atualizar_leitura((SELECT MAX(id_leitura) FROM leitura_consumo), 88.8);
SELECT * FROM leitura_consumo WHERE valor_watts = 88.8;

DELIMITER //
CREATE PROCEDURE sp_excluir_leitura(IN p_id BIGINT)
BEGIN
    UPDATE leitura_consumo SET ativo = 0 WHERE id_leitura = p_id;
END //
DELIMITER ;

CALL sp_excluir_leitura((SELECT MAX(id_leitura) FROM leitura_consumo));
SELECT * FROM leitura_consumo WHERE valor_watts = 88.8;

DELIMITER //
CREATE PROCEDURE sp_incluir_notificacao(IN p_titulo VARCHAR(50), IN p_msg VARCHAR(255), IN p_disp_id INT)
BEGIN
    INSERT INTO notificacao (titulo, mensagem, fk_dispositivo_id) VALUES (p_titulo, p_msg, p_disp_id);
END //
DELIMITER ;

CALL sp_incluir_notificacao('Teste Notif', 'Mensagem teste', 1);
SELECT * FROM notificacao WHERE titulo = 'Teste Notif';

DELIMITER //
CREATE PROCEDURE sp_atualizar_notificacao(IN p_id INT, IN p_lida TINYINT(1))
BEGIN
    UPDATE notificacao SET lida = p_lida WHERE id_alerta = p_id;
END //
DELIMITER ;

CALL sp_atualizar_notificacao((SELECT MAX(id_alerta) FROM notificacao), 1);
SELECT * FROM notificacao WHERE titulo = 'Teste Notif';

DELIMITER //
CREATE PROCEDURE sp_excluir_notificacao(IN p_id INT)
BEGIN
    UPDATE notificacao SET ativo = 0 WHERE id_alerta = p_id;
END //
DELIMITER ;

CALL sp_excluir_notificacao((SELECT MAX(id_alerta) FROM notificacao));
SELECT * FROM notificacao WHERE titulo = 'Teste Notif';

DELIMITER //
CREATE PROCEDURE sp_incluir_automacao(IN p_acao VARCHAR(10), IN p_hora TIME, IN p_freq VARCHAR(20), IN p_disp_id INT)
BEGIN
    INSERT INTO automacao (acao, horario, frequencia, fk_dispositivo_id) VALUES (p_acao, p_hora, p_freq, p_disp_id);
END //
DELIMITER ;

CALL sp_incluir_automacao('TESTE', '12:00:00', 'DIARIO', 1);
SELECT * FROM automacao WHERE acao = 'TESTE';

DELIMITER //
CREATE PROCEDURE sp_atualizar_automacao(IN p_id INT, IN p_hora TIME, IN p_freq VARCHAR(20))
BEGIN
    UPDATE automacao SET horario = p_hora, frequencia = p_freq WHERE id_automacao = p_id;
END //
DELIMITER ;

CALL sp_atualizar_automacao((SELECT MAX(id_automacao) FROM automacao), '13:00:00', 'SEMANAL');
SELECT * FROM automacao WHERE acao = 'TESTE';

DELIMITER //
CREATE PROCEDURE sp_excluir_automacao(IN p_id INT)
BEGIN
    UPDATE automacao SET ativo = 0 WHERE id_automacao = p_id;
END //
DELIMITER ;

CALL sp_excluir_automacao((SELECT MAX(id_automacao) FROM automacao));
SELECT * FROM automacao WHERE acao = 'TESTE';

DELIMITER //
CREATE PROCEDURE sp_incluir_data(IN p_dia VARCHAR(15), IN p_data DATE)
BEGIN
    INSERT INTO data_alvo (nome_dia, data_especifica) VALUES (p_dia, p_data);
END //
DELIMITER ;

CALL sp_incluir_data('Feriado', '2025-01-01');
SELECT * FROM data_alvo WHERE nome_dia = 'Feriado';

DELIMITER //
CREATE PROCEDURE sp_atualizar_data(IN p_id INT, IN p_dia VARCHAR(15), IN p_data DATE)
BEGIN
    UPDATE data_alvo SET nome_dia = p_dia, data_especifica = p_data WHERE id_data = p_id;
END //
DELIMITER ;

CALL sp_atualizar_data((SELECT MAX(id_data) FROM data_alvo), 'Feriado Alt', '2025-01-02');
SELECT * FROM data_alvo WHERE nome_dia = 'Feriado Alt';

DELIMITER //
CREATE PROCEDURE sp_excluir_data(IN p_id INT)
BEGIN
    UPDATE data_alvo SET ativo = 0 WHERE id_data = p_id;
END //
DELIMITER ;

CALL sp_excluir_data((SELECT MAX(id_data) FROM data_alvo));
SELECT * FROM data_alvo WHERE nome_dia = 'Feriado Alt';

DELIMITER //
CREATE PROCEDURE sp_incluir_agendamento(IN p_auto_id INT, IN p_data_id INT)
BEGIN
    INSERT INTO agendamento (fk_automacao_id, fk_data_alvo_id) VALUES (p_auto_id, p_data_id);
END //
DELIMITER ;

CALL sp_incluir_agendamento(2, 2);
SELECT * FROM agendamento WHERE fk_automacao_id = 2 AND fk_data_alvo_id = 2;

DELIMITER //
CREATE PROCEDURE sp_atualizar_agendamento(IN p_auto_id INT, IN p_data_antiga INT, IN p_data_nova INT)
BEGIN
    UPDATE agendamento SET fk_data_alvo_id = p_data_nova 
    WHERE fk_automacao_id = p_auto_id AND fk_data_alvo_id = p_data_antiga;
END //
DELIMITER ;

CALL sp_atualizar_agendamento(2, 2, 3);
SELECT * FROM agendamento WHERE fk_automacao_id = 2;

DELIMITER //
CREATE PROCEDURE sp_excluir_agendamento(IN p_auto_id INT, IN p_data_id INT)
BEGIN
    UPDATE agendamento SET ativo = 0 
    WHERE fk_automacao_id = p_auto_id AND fk_data_alvo_id = p_data_id;
END //
DELIMITER ;

CALL sp_excluir_agendamento(2, 3);
SELECT * FROM agendamento WHERE fk_automacao_id = 2;

CREATE VIEW vw_detalhes_dispositivos AS
SELECT 
    d.id_dispositivo,
    d.nome_dispositivo AS Aparelho,
    c.nome_comodo AS Localizacao,
    u.nome AS Proprietario,
    s.descricao AS Status_Rede,
    d.potencia_nominal AS Watts
FROM dispositivo d
JOIN comodo c ON d.fk_comodo_id = c.id_comodo
JOIN usuario u ON d.fk_usuario_id = u.id_usuario
JOIN status_conexao s ON d.fk_status_id = s.id_status
WHERE d.ativo = 1;

SELECT * FROM vw_detalhes_dispositivos;

CREATE VIEW vw_dispositivos_alerta AS
SELECT 
    d.nome_dispositivo,
    c.nome_comodo,
    s.descricao AS Problema_Detectado
FROM dispositivo d
JOIN status_conexao s ON d.fk_status_id = s.id_status
JOIN comodo c ON d.fk_comodo_id = c.id_comodo
WHERE s.descricao IN ('Offline', 'Erro', 'Desconhecido', 'Bateria Fraca') AND d.ativo = 1;

SELECT * FROM vw_dispositivos_alerta;

CREATE VIEW vw_automacoes_dispositivo AS
SELECT 
    d.nome_dispositivo,
    a.acao AS Acao_Programada,
    a.horario,
    a.frequencia
FROM dispositivo d
JOIN automacao a ON d.id_dispositivo = a.fk_dispositivo_id
WHERE d.ativo = 1 AND a.ativo = 1;

SELECT * FROM vw_automacoes_dispositivo;

CREATE VIEW vw_notificacoes_pendentes AS
SELECT 
    n.titulo,
    n.mensagem,
    n.data_envio,
    d.nome_dispositivo
FROM notificacao n 
JOIN dispositivo d ON n.fk_dispositivo_id = d.id_dispositivo
WHERE n.lida = 0 AND n.ativo = 1;

SELECT * FROM vw_notificacoes_pendentes;

CREATE VIEW vw_resumo_status AS
SELECT 
    s.descricao AS Status, 
    COUNT(d.id_dispositivo) AS Quantidade
FROM status_conexao s 
LEFT JOIN dispositivo d ON s.id_status = d.fk_status_id AND d.ativo = 1
GROUP BY s.descricao;

SELECT * FROM vw_resumo_status;

CREATE INDEX idx_usuario_email ON usuario(email);

EXPLAIN SELECT * FROM usuario WHERE email = 'rafael@powerhome.com';

CREATE INDEX idx_dispositivo_mac ON dispositivo(endereco_mac);

EXPLAIN SELECT * FROM dispositivo WHERE endereco_mac = 'AA:BB:CC:00:01';

CREATE INDEX idx_leitura_data ON leitura_consumo(data_hora);

EXPLAIN SELECT * FROM leitura_consumo WHERE data_hora = '2025-11-28 10:00:00';

START TRANSACTION;

    UPDATE dispositivo SET estado_atual = 0 WHERE fk_comodo_id = 1;
    INSERT INTO notificacao (titulo, mensagem, lida, fk_dispositivo_id)
    VALUES (
        'Manutenção', 
        'Dispositivos da sala desligados preventivamente.', 
        0, 
        (SELECT id_dispositivo FROM dispositivo WHERE endereco_mac = 'AA:BB:CC:00:01')
    );

COMMIT;

SELECT nome_dispositivo, estado_atual FROM dispositivo WHERE fk_comodo_id = 1;

SELECT * FROM notificacao WHERE titulo = 'Manutenção';