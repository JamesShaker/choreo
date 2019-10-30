# Bakery : Payload to CakeML Compilation

[![Build Status](https://travis-ci.org/CakeML/choreo.svg?branch=master)](https://travis-ci.org/CakeML/choreo)
## Table of Contents
1. [Repo Overview](#repo-overview)
	1. [What is this repo?](#what-is-this-repo)
	2. [What is the context?](#what-is-the-context)
	3. [What have I done?](#what-have-i-done)
2. [Code Breakdown](#code-breakdown)
	1. [Payload Syntax, Semantics, and Compilation](#payload-syntax-semantics-and-compilation)
	2. [Automation Tools and Theorems](#automation-tools-and-theorems)
	3. [FFI Modelling and Proofs](#ffi-modelling-and-proofs)
	4. [Compilation Correctness Proofs](#compilation-correctness-proofs)

## Repo Overview

### What is this repo?
This repository contains the work I have completed as part of my honours
project. I worked on verified compilation from a [choreographic language](https://www.fabriziomontesi.com/files/choreographic_programming.pdf "Montesi 2013") called Payload to a functional
sequential language called [CakeML](https://cakeml.org/). My work is implemented
in the [Higher Order Logic (HOL) theorem prover](https://hol-theorem-prover.org/).
### What is the context?
My work is part of the [Bakery project](
https://ts.data61.csiro.au/publications/csiro_full_text//GomezLondono_AAmanPohjola_18.pdf
"Gomez-Londono and Pohjola 2018") which aims to provide verified compilation of
a proof-of-concept choreographic language (called Bakery). Choreoraphic languages
are cool because you can implement concurrent systems with multiple nodes as
one piece of code. This automates the *projection* process of moving from global design
to individual sequential implementations. The Bakery project aims to demonstrate
this change in abstraction when using choreographies will make concurrent systems
more amenable to verification. Of course this is only useful if compilation is trustworthy!

Payload is an intermediate language in the Bakery stack, and in fact Payload to CakeML is the 
final planned stage of Bakery compilation. Past this point we plan to use the CakeML compiler to generate machine code. CakeML has a formal [functional big-step semantics](https://cakeml.org/esop16.pdf "Owens et. al. 2016") in the [Higher Order Logic (HOL)
theorem prover](https://hol-theorem-prover.org/) and a verified compiler, also in HOL,
to produce machine code. Thus we hope to implement verified compilation from Payload
into CakeML in HOL.

The main Bakery project repository is [here](https://github.com/CakeML/choreo)
(and confusingly called `choreo`!). My work sits on the `cake` branch and is designed to integrate with the work of others. In this personal repository I've isolated the elements
relevant to Payload to  CakeML compilation implementation and verification. To compare this 
stage and the broader project with and without my contributions checkout the
`master` branch of the main Bakery repo and compare it to this repository or
the `cake` branch. There are some minor differences in how this repository is organised
to make things easier to understand but no changes of real consequence have been made.

### What have I done?
Here is a summary of my contributions:
* Refinement and correction of the project’s initial (buggy) compilation function (written by others)
* Production of an FFI model of communication and networks within the CakeML semantics framework
* Development of a model of correctness to reconcile Payload’s concurrent small- step semantics and CakeML’s sequential functional big-step semantics
* Development of theorem proving technology for automation of proofs involv- ing CakeML semantics
* Foundational proofs:
    * Correctness of send and receive primitives
    * Many FFI confluence/commutativity proofs
    * FFI equivalence implies lockstep progress
    * All but one case of FFI irrelevance to program execution

## Code Breakdown
### Payload Syntax, Semantics, and Compilation
### Automation Tools and Theorems
### FFI Modelling and Proofs
### Compilation Correctness Proofs