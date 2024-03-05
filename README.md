<h1> Estação Metereológica </h1>

![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)
<h2> Descrição do Projeto </h2>
  Projeto em desenvolvimento para a Iniciação Científica do curso Engenharia da Computação no CEFET-MG/Campus-V. A Estação Metereológica é um sistema de monitoramento do ambiente focado para pequenos e médios agricultores. 
  A Estação permitirá o monitoramento em tempo real e remoto, além de disponibilizar os dados coletados para o usuário.
  
<h2> Funcionalidades e Desmonstração da Aplicação </h2>
  A estação meteorológica tem como finalidade realizar coleta e medição de dados climáticos do ambiente onde se encontra, como: 
  
  - `Temperatura`: Com o sensor DHT11 é possível medir a temperatura do ambiente. 
  - `Umidade`: Com o sensor DHT11 é possível também medir a umidade do ambiente.
  - `Umidade do solo`: Com o sensor Higrômetro permite medir a umidade do solo.
  - `Detecção de chuva`: Com o sensor de chuva detecta a presença de chuva no ambiente. 
  - `Pressão Atmosférica`: Com o sensor BMP180 realiza a medição da pressão atmosféria do ambiente. 
  - `Altitude`: Com o mesmo sensor BMP180 também realiza a medição da altitude.
  - `Velocidade do vento`: Utilizando o sensor de obstáculos Reflexivo e a montagem de um Anemômetro, é possivel realizar a medição da velocidade do vento. 

<h2> Tecnologias Utilizadas </h2>


  - `Linguagem de Programação`: C para programação do circuito.
  - `Plataforma de Hardware`: Esp32 com diversos sensores, incluindo:
    -  `DHT11` (Temperatura e Umidade)
    -  `Higrômetro` (Umidade do solo)
    -  `Sensor de chuva`
    - `BMP180` (Pressão atmosférica e Altitude)
    - `Sensor de obstáculos` Reflexivo com Anemômetro (Velocidade do vento)
  - `Prototipagem`: Filamento e impressora 3D para o protótipo.
  - `Aplicativo`: Flutter para desenvolvimento de aplicativo móvel.
  - `Banco de Dados`: Firebase.

<h2> O protótipo<h2>

   O protótipo da Estação Meteorológica do Projeto Evet é uma solução integrada de monitoramento climático desenhada especificamente para atender às necessidades dos agricultores, permitindo-lhes acessar dados climáticos precisos e em tempo real para melhorar a tomada de decisões e otimizar a produção agrícola.
   
<h3> Componentes e Funcionalidades </h3>

  
  - `Sensor DHT11`: Utilizado para medir a temperatura e a umidade do ar, o DHT11 é a escolha ideal para obter leituras precisas do clima, essenciais para o planejamento agrícola.
  - `Higrômetro`: Este sensor mede a umidade do solo, fornecendo dados valiosos para garantir a irrigação adequada e evitar o estresse hídrico das plantas.
  - `Sensor de Chuva`: Detecta a presença de chuva, permitindo aos agricultores adaptar rapidamente suas práticas de plantio e irrigação às condições climáticas em mudança.
  - `Sensor BMP180`: Mede a pressão atmosférica e a altitude, oferecendo insights sobre as condições climáticas que podem afetar a saúde das plantas e a eficácia dos pesticidas.
  - `Sensor de obstáculos Reflexivo com Anemômetro`: Avalia a velocidade do vento, fornecendo dados críticos para a proteção das culturas e estruturas agrícolas contra danos causados por ventos fortes.
  <h2> Design </h2>
   O protótipo apresenta um design modular e compacto, facilitando a instalação em diversos ambientes agrícolas. Com componentes eletrônicos alojados em uma caixa protetora impressa em 3D, o dispositivo é projetado para resistir a condições externas adversas, como chuva, poeira e exposição solar prolongada. 
   <img src="/src/img/Arquivo1.png">

   <img src="/src/img/Arquivo4.jpg">

   <img src="/src/img/Arquivo2.jpg">

   <img src="/src/img/Arquivo3.jpg">



<h2> O Aplicativo<h2>
   
  Integrado com tecnologia de conectividade avançada, o protótipo transmite dados em tempo real para um aplicativo móvel desenvolvido em Flutter, permitindo aos usuários visualizar as condições climáticas atuais através de uma interface intuitiva. O uso do Firebase como banco de dados assegura o armazenamento seguro e a fácil recuperação de dados climáticos históricos, habilitando análises detalhadas e a previsão de tendências climáticas.
