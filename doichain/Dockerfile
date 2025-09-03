FROM davidreband/doichain-base:dc29-test

ARG DOICHAIN_VER=doichain-nc29-migration 
ENV DOICHAIN_VER $DOICHAIN_VER

#Install doichain-core (updated version for nc29-migration testing)
WORKDIR /home/doichain
RUN mkdir .doichain && \
	sudo git clone --branch $DOICHAIN_VER https://github.com/davidreband/doichain-core.git && \
	cd doichain-core && \
	sudo cmake -B build -DBUILD_GUI=OFF -DENABLE_TESTS=OFF -DWITH_BDB=ON -DBDB_LIBRARY=/usr/local/BerkeleyDB.4.8/lib/libdb_cxx-4.8.a -DBDB_INCLUDE_DIR=/usr/local/BerkeleyDB.4.8/include && \
	sudo cmake --build build && \
	sudo cmake --install build

#Copy start scripts
WORKDIR /home/doichain/scripts/
COPY entrypoint.sh entrypoint.sh
COPY start.sh start.sh
COPY getblocktimes.sh getblocktimes.sh
COPY doichain-start.sh doichain-start.sh

RUN sudo dos2unix \
	entrypoint.sh \
	start.sh \
	doichain-start.sh && \
	sudo chmod +x \
	entrypoint.sh \
	start.sh \
	doichain-start.sh \
	getblocktimes.sh && \
	sudo apt-get purge -y dos2unix && \
	sudo rm -rf /var/lib/apt/lists/*

#Create data dir
WORKDIR /home/doichain
RUN mkdir data && \
	cd data && \
	mkdir doichain &&\
	sudo rm -rf /home/doichain/.doichain && \
	sudo ln -s /home/doichain/data/doichain /home/doichain/.doichain

#Run entrypoint
WORKDIR /home/doichain
ENTRYPOINT ["scripts/entrypoint.sh"]

#Start doichain and meteor
CMD ["scripts/start.sh"]

#Expose ports
EXPOSE $NODE_PORT $RPC_PORT $RPC_PORT_REGTEST
