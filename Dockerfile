FROM CakeML/cakeml

RUN mkdir bakery/
COPY --chown=cake . bakery/

RUN cd bakery && Holmake
RUN cd bakery/proofs && Holmake
