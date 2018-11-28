open preamble payloadLangTheory astTheory
     

val _ = new_theory "payload_to_cakeml";

val letfuns_def = Define `
   (letfuns payloadLang$Nil = [])
∧ (letfuns (Send p v n e) = letfuns e)
∧ (letfuns (Receive p v l e) = letfuns e)
∧ (letfuns (IfThen v e1 e2) = letfuns e1 ++ letfuns e2)
∧ (letfuns (Let v f vl e) = f::letfuns e)`

val buffer_size_def = Define
  `buffer_size conf = Lit(IntLit(&(conf.payload_size + 1)))`

val payload_size_def = Define
  `payload_size conf = Lit(IntLit(&conf.payload_size))`

(* TODO: let length x *)
val padv_def = Define
  `padv conf =
   Fun "x"
   (Let (SOME "y")
    (App Aw8alloc [buffer_size conf;Lit(Word8 0w)])
    (If (App Equality [App Opapp [Var conf.length;Var(Short "x")];payload_size conf])
     (Let NONE (App Aw8update [Var(Short "y");Lit(IntLit 0);Lit(Word8 7w)])      
       (Let
         (SOME "z")
         (App Opapp [Var conf.fromList;App Opapp [App Opapp [Var conf.take; Var(Short"x")]; payload_size conf]])
         (Let NONE
           (App CopyAw8Aw8 [Var(Short "z"); Lit(IntLit 0); payload_size conf;
                            Var(Short "y"); Lit(IntLit 1)])
           (Var(Short "y"))
         )
       )
     )
     (If (App (Opb Lt) [App Opapp [Var conf.length;Var(Short "x")];payload_size conf])
      (Let NONE (App Aw8update [Var(Short "y");Lit(IntLit 0);Lit(Word8 6w)])
        (Let (SOME "z") (App Opapp [Var conf.fromList;Var(Short"x")])
          (Let NONE
            (App Aw8update
                 [Var(Short "y");
                  App (Opn Minus)
                      [payload_size conf;
                       App Aw8length [Var(Short "z")]];
                  Lit(Word8 1w)
                 ]
            )
            (Let NONE
              (App CopyAw8Aw8
                   [Var (Short "z");
                    Lit(IntLit 0);
                    App Aw8length [Var(Short "z")];
                    Var(Short "y");
                    App (Opn Plus)
                        [Lit(IntLit 1);
                         App (Opn Minus)
                             [payload_size conf;App Aw8length [Var(Short "z")]]
                        ]
                   ]
              )
              (Var (Short "y"))
            )
          )
        )
      )
      (Let NONE (App Aw8update [Var(Short "y");Lit(IntLit 0);Lit(Word8 2w)])
       (Let
         (SOME "z")
         (App Opapp [Var conf.fromList;App Opapp [App Opapp [Var conf.take; Var(Short"x")]; payload_size conf]])
         (Let NONE
           (App CopyAw8Aw8 [Var(Short "z"); Lit(IntLit 0); payload_size conf;
                            Var(Short "y"); Lit(IntLit 1)])
           (Var (Short "y"))
         )
       )
      )
     )
    )
   )
`

val sendloop_def = Define `sendloop conf dest = 
   [("sendloop","x",
     Let (SOME "y")
       (App Opapp [padv conf;Var(Short "x")])
       (Let NONE
         (App (FFI "send") [Lit(StrLit dest); Var (Short "y")])
         (If
           (App (Opb Leq) [App Opapp [Var conf.length; Var(Short "x")];
                           payload_size conf]
           )
           (Con NONE [])
           (Let (SOME "x") (App Opapp [App Opapp [Var conf.drop; Var (Short "x")];
                                       payload_size conf])
                (App Opapp [Var(Short "sendloop"); Var(Short "x")])
           )
         )
       )
    )]`

val find_one_def = Define
  `find_one =
   [("find_one","n",
     If (App Equality [Lit (Word8 1w); App Aw8sub [Var(Short "x"); Var(Short "n")]])
       (Var (Short "n"))
       (App Opapp [Var(Short "find_one"); App (Opn Plus) [Var(Short "n"); Lit(IntLit 1)]])
   )]`

val finalv_def = Define
  `final x =
   Log Or
       (App Equality [Lit (Word8 7w); App Aw8sub [Var(Short x); Lit(IntLit 0)]])
       (App Equality [Lit (Word8 2w); App Aw8sub [Var(Short x); Lit(IntLit 0)]])`

val unpadv_def = Define
  `unpadv conf = 
   Fun "x"
   (Let (SOME "n")
     (If (final "x")
        (Lit(IntLit 1))
        (Letrec find_one (App Opapp [Var(Short "find_one"); Lit(IntLit 1)]))
     )
     (Let (SOME "y")
          (App Aw8alloc
               [App (Opn Minus)
                    [App Aw8length [Var (Short "x")];
                     Var(Short "n")];
                Lit(Word8 0w)
               ]
          )
          (Let NONE
               (App CopyAw8Aw8
                    [Var(Short "x");
                     Var(Short "n");
                     App Aw8length [Var (Short "y")];
                     Lit(IntLit 0)
                    ]
               )
               (App Opapp [Var conf.toList; Var(Short "y")]
               )
          )
     )
     )
  `

val receiveloop_def = Define `receiveloop conf src =
  [("receiveloop","u",
    (Let NONE (App (FFI "receive") [Lit(StrLit src); Var(Short "buff")])
       (If (final "buff")
          (Con (SOME conf.cons)
               [App Opapp [unpadv conf;Var(Short "buff")];
                Con(SOME conf.nil) []])
          (Con(SOME conf.cons)
               [App Opapp [unpadv conf;Var(Short "buff")];
                App Opapp [Var(Short "receiveloop");Var(Short "u")]
               ]
          )
       )
    )
  )]`

val compile_endpoint_def = Define `
   (compile_endpoint conf vs payloadLang$Nil = Con NONE [])
∧ (compile_endpoint conf vs (Send p v n e) =
    let vv = Var(Short v) in
      If (App (Opb Leq) [App Opapp [Var conf.length; vv]; Lit(IntLit(&n))])
         (compile_endpoint conf vs e)
         (Let NONE
           (Letrec
              (sendloop conf (MAP (CHR o w2n) p))
              (App Opapp [Var(Short "sendloop");vv])
           )
           (compile_endpoint conf vs e)
         )
  )
∧ (compile_endpoint conf vs (Receive p v l e) =
    Let (SOME v)
        (Let (SOME "buff") (App Aw8alloc [buffer_size conf;Lit(Word8 0w)])
             (Letrec
                (receiveloop conf (MAP (CHR o w2n) p))
                (App Opapp
                     [Var conf.concat;
                      App Opapp [Var(Short "receiveloop"); Con NONE []]
                     ]
                )
             )
        )
        (compile_endpoint conf vs e)
   )
∧ (compile_endpoint conf vs (IfThen v e1 e2) =
   let vn = LENGTH(letfuns e1) in
     If (Var(Short v))
        (compile_endpoint conf (TAKE vn vs) e1)
        (compile_endpoint conf (DROP vn vs) e2))
∧ (compile_endpoint conf (hv::vs) (payloadLang$Let v f vl e) =
   ast$Let (SOME v)
       (App Opapp (hv::MAP (Var o Short) vl))
       (compile_endpoint conf vs e))`

val _ = export_theory ();
