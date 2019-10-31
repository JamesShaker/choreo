# Bakery : Payload to CakeML Compilation

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
Here I describe what is in each file. Most
of the 'Payload Syntax, Semantics, and Compilation' I was
already provided and modified or fixed. On the other hand
the 'Automation Tools and Theorems' and 'FFI Modelling and Proofs'
I devised almost entirely from scratch. The 'Compilation Correctness Proofs'
contain some elements produced by others, however I completed
the bulk of the work.
### Payload Syntax, Semantics, and Compilation
At the top level we have several files describing language models and
compilation:
#### `payloadLangScript.sml`
Contains the type descriptions for Payload's AST, `endpoint`, and representation of state, `state`. Also has a `network` type to combine these into `NEndpoint`
nodes or `NPar` two sub-`network`s together. Most of this was completed by others in the Bakery project, however I modified state with a new model for `queues`.
#### `payloadSemanticsScript.sml`
Contains Payload's small-step semantics in the
`trans` inductive relation. Defines `label` and helper functions regarding the Payload
message protocol to support `trans`.  Again, most of this was completed by others in the Bakery project, however I adjusted `trans` to support the new model of `queues`.
#### `payload_to_cakemlScript.sml`
Contains implementation of compilation in `compile_endpoint`
function. This function and the helpers were all initially written by others but
quite buggy. I rectified many issues. 

### Automation Tools and Theorems
I made these to assist in my intircate proofs involving the complex
CakeML semantics.
#### `proofs/lib_tools/state_tacticLib.sml`
Often extra values needed to be added to the `clock` in CakeML semantics
manual evaluation to ensure no timeout. This addition of fuel causes expressions
to blow up into long chains of addition as more steps are taken. Here
we define the `unite_nums` tactic. Given a string it tries to reduce the first
list of right-associated added free variables it finds in the goal.
#### `proofs/lib_tools/evaluate_rwLib.sml`
Rewrite lists combining all relevant CakeML functions to run semantics as
far as possible either in its entirety, without function application, or without
FFI.
#### `proofs/theory_tools/evaluate_toolsScript.sml`
Some low-level theorems. `evaluate_generalise` allows results for
evaluation in the `empty_state` to be used in more complex states with
extra fuel. `do_opapp_translate` is designed to allow function application
of translated functions to be performed in any state with some ease.
#### `proofs/theory_tools/ckExp_EquivScript.sml`
We define an entire framework for CakeML AST to HOL equivalence with
tools for building equivalence statements about more complex expressions
from simpler ones. Also includes different ways equivalence can be applied to reduce
evaluation. Built on top of the basic HOL/CakeML translation framework.

### FFI Modelling and Proofs
This is the most complex section and built from scratch.
#### `proofs/ffi/bisimulation_extScript.sml`
In here I define an alternative formulation of the bisimulation relation
based on a coinductive relation called `bi`. We prove it equal and we also
prove that the bisimulation relation is an equivalence. This will hopefully
be PRd into the main HOL repo at some point. It allow proofs involving bisimulation
to exploit coinduction.
#### `proofs/ffi/confluenceScript.sml`
We define a set of general theorems regarding how different variations on the diamond
property relate. In particular we are interested in reflexive closures, and reflexive,
transitive closure variants.
#### `proofs/ffi/payloadPropsScript.sml`
This is a long complex theory. In it we prove reflexive closure confluence for
the `trans` Payload small-step semantics. There are around 60 cases considered in various
proofs and the file totals over 1600 lines.
#### `proofs/ffi/comms_ffi_modelScript.sml`
Here we define the `total_state` type to model FFI, the `strans` system
around it, and the `comms_ffi_oracle` to provide an interface. This model
is built on top of the Payload `trans` model.
#### `proofs/ffi/comms_ffi_consScript.sml`
In this theory I devise simpler transition steps (`active_trans`,
`internal_trans`, `input_trans`, and `output_trans`) to those in `strans`. I
prove that these smaller steps can be combined to produce `strans` step
and that every `strans` step can be reduced to these smaller steps. This
construction and deconstruction framework is used extensively in all the
other FFI proofs
#### `proofs/ffi/comms_ffi_propsScript.sml`
This contains a large set of proofs and properties around
the `strans` transition that are varied. Notions of states
being able to `send` or `receive` as well as well-formedness 
are included.
#### `proofs/ffi/comms_ffi_commScript.sml`
I prove that the RTC of `active_trans` and the RTC of `internal_trans`
(we use RTC to indicate the reflexive and transitive closure)
both have the diamond property with `input_trans` and `output_trans`.
This is built off `payloadPropScript.sml` confluence results for
`trans`. I then go to use these results to show that
`strans` holds the diamond property with the RTC of `active_trans`
and the RTC of `internal_trans`.
#### `proofs/ffi/comms_ffi_eqScript.sml`
Here I define `ffi_eq` to give a notion of equivalence on
FFI states based on bisimulation. I then show that two
equivalent states must remain equivalent if they pass through
the same `strans` transition. This is a complex proof involving
deconstruction (`comms_ffi_consScript` tools), followed
by proving that states before
and after `active_trans` and `internal_trans` steps
are equivalent (using coinduction from `bisimulation_extScript`,
followed by `strans` commutativity from `comms_ffi_commScript`),
and finally proofs that `input_trans` or `output_trans` steps
taken identically from two equivalent states preserve equality
(`comms_ffi_consScript` tools and commutativity results
from `comms_ffi_commScript`). We show certain send and receive
properties are the same for equivalent states.

### Compilation Correctness Proofs
#### `proofs/payload_to_cakemlProofScript.sml`
Here the main proofs around correctness are done.
Highlights of my contributions are `receiveloop_correct`,
four out of five cases proven in `ffi_irrel`, and the specification 
for forward correctness in `forward_correctness`. The
`ffi_irrel` lemma, I suggest, contains most of the work that will
be needed in the `forward_correctness` proof. It says that compiled
Payload code run under two coherent CakeML states with equivalent FFI
result in equivalent ouput. Notions of 'correspondence', 'validity',
and 'equivalence' connecting Payload code and states, CakeML code and states,
and Payload transitions are all defined and referred to in this file.

