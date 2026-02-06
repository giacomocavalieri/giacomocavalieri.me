import{$ as B,A as L,B as V,C as P,D as r,E as l,G as c,H as n,K as d,M as a,N as s,O as b,P as i,Q as A,R as m,U as o,V as t,W as U,X as Q,Y as e,Z as S,_ as qq,a as X,aa as Y,b as w,ba as zq,c as q,ca as Jq,da as Nq,e as T,g as p,ga as Qq,ha as Sq,ia as Vq,j as v,ja as Xq,k as R,m as _,o as g,s as C,w as W}from"./birdie_terminal-p7qxhfff.js";var Eq="src/blog/interactive/birdie_terminal.gleam";class k extends X{constructor(z,J,N,x){super();this.state=z,this.command=J,this.ran_commands=N,this.tests_timing=x}}class h extends X{}class f extends X{}class H extends X{}class M extends X{}class G extends X{}class y extends X{constructor(z){super();this.command=z}}class F extends X{constructor(z){super();this[0]=z}}class Yq extends X{constructor(z){super();this.tests_timing=z}}class I extends X{}class O extends X{}class E extends X{}class K extends X{}class Zq extends X{constructor(z){super();this.value=z}}function Kq(z){return[new k(new h,"",q([]),z),b()]}function bq(){return i((z)=>{return z(new Yq(1+W(6)))})}function fq(z){return A((J,N)=>{return Xq(z)})}function hq(z){return A((J,N)=>{return Vq(z)})}function Z(z){if(z instanceof I)return"gleam test";else if(z instanceof O)return"gleam run -m birdie";else if(z instanceof E)return"a";else if(z instanceof K)return"r";else return z.value}function Dq(z,J){let N;if(N=z.state,N instanceof h)if(J instanceof I)return[new f,U("","code",q([]),`<span class='hljs-shell-error'>panic</span> test/example_test.gleam:9
 <span class='hljs-shell-info'>test</span>: example_test.usage_text_test
 <span class='hljs-shell-info'>info</span>: Birdie snapshot test failed

── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run \`gleam run -m birdie\` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + usage: lucysay [-m message] [-f file]
      2 +
      3 +  -m, --message  the message to be printed
      4 +  -f, --file     a file to read the message from
      5 +  -h, --help     show this help text</span>
────────┴───────────────────────────────────────────────────

Finished in 0.00`+C(z.tests_timing)+` seconds
<span class='hljs-shell-error'>1 tests, 1 failures</span>`)];else if(J instanceof O)return[N,B(q([]),q([Q(`\uD83D\uDC26‍⬛ No new snapshots to review
`),Y(q([V("hljs-shell-info")]),q([Q("Hint")])),Q(": "),Y(q([V("hljs-shell-warning")]),q([Q("did you forget to run `gleam test`?")]))]))];else if(J instanceof E)return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else if(J instanceof K)return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else if(N instanceof f)if(J instanceof I)return[new f,U("","code",q([]),`<span class='hljs-shell-error'>panic</span> test/example_test.gleam:9
 <span class='hljs-shell-info'>test</span>: example_test.usage_text_test
 <span class='hljs-shell-info'>info</span>: Birdie snapshot test failed

── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run \`gleam run -m birdie\` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + usage: lucysay [-m message] [-f file]
      2 +
      3 +  -m, --message  the message to be printed
      4 +  -f, --file     a file to read the message from
      5 +  -h, --help     show this help text</span>
────────┴───────────────────────────────────────────────────

Finished in 0.00`+C(z.tests_timing)+` seconds
<span class='hljs-shell-error'>1 tests, 1 failures</span>`)];else if(J instanceof O)return[new H,U("","code",q([]),`Reviewing <span class='hljs-shell-warning'>1st</span> out of <span class='hljs-shell-warning'>1</span>

── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>file</span>: ./test/cli.gleam
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + usage: lucysay [-m message] [-f file]
      2 +
      3 +  -m, --message  the message to be printed
      4 +  -f, --file     a file to read the message from
      5 +  -h, --help     show this help text</span>
────────┴───────────────────────────────────────────────────

  <span class='hljs-shell-new'>a</span> accept     accept the new snapshot
  <span class='hljs-shell-error'>r</span> reject     reject the new snapshot`)];else if(J instanceof E)return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else if(J instanceof K)return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else if(N instanceof H)if(J instanceof I)return[new H,S(q([]),q([Q("the options are [a]ccept or [r]eject")]))];else if(J instanceof O)return[new H,S(q([]),q([Q("the options are [a]ccept or [r]eject")]))];else if(J instanceof E)return[new M,S(q([]),q([Q("\uD83D\uDC26‍⬛ "),Y(q([V("hljs-shell-new")]),q([Q("Accepted one snapshot")]))]))];else if(J instanceof K)return[new h,S(q([]),q([Q("\uD83D\uDC26‍⬛ "),Y(q([V("hljs-shell-error")]),q([Q("Rejected one snapshot")]))]))];else return[new H,S(q([]),q([Q("the options are [a]ccept or [r]eject")]))];else if(N instanceof M)if(J instanceof I)return[new G,B(q([]),q([Y(q([V("hljs-shell-new")]),q([Q(`.
1 passed, no failures`)]))]))];else if(J instanceof O)return[N,B(q([]),q([Q(`\uD83D\uDC26‍⬛ No new snapshots to review
`),Y(q([V("hljs-shell-info")]),q([Q("Hint")])),Q(": "),Y(q([V("hljs-shell-warning")]),q([Q("did you forget to run `gleam test`?")]))]))];else if(J instanceof E)return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else if(J instanceof K)return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else return[N,S(q([]),q([Q("unknown command: "+Z(J))]))];else return[new G,o()]}function Pq(z){let J=g(z);if(J==="gleam test")return new I;else if(J==="gleam run -m birdie")return new O;else if(J==="a")return new E;else if(J==="r")return new K;else return new Zq(J)}function kq(z,J){if(J instanceof y){let N=J.command;return[new k(z.state,N,z.ran_commands,z.tests_timing),b()]}else if(J instanceof F)if(J[0]==="Enter"){let x=Pq(z.command),D=Dq(z,x),$,u;$=D[0],u=D[1];let Hq=w([x,u],z.ran_commands),Iq=new k($,"",Hq,z.tests_timing),j;if(x instanceof I)j=bq();else j=b();let Oq=j;return[Iq,m(q([hq("terminal-prompt-field"),fq("terminal-prompt-field"),Oq]))]}else return[z,b()];else{let N=J.tests_timing;return[new k(z.state,z.command,z.ran_commands,N),b()]}}function Mq(z){if(z instanceof h)return"try running `gleam test`...";else if(z instanceof f)return"try running `gleam run -m birdie`";else if(z instanceof H)return"try accepting the snapshot with `a`";else if(z instanceof M)return"try running `gleam test` again now...";else return"the demo is over!"}function Uq(z){let J=R(v(z.ran_commands),(N)=>{let x,D;return x=N[0],D=N[1],S(q([V("stack-xs")]),q([S(q([V("with-icon")]),q([Y(q([V("icon hljs-comment")]),q([Q(">")])),Y(q([V("hljs-comment")]),q([Q(Z(x))]))])),D]))});return t(q([qq(q([V("stack-s")]),_(J,q([S(q([V("with-icon")]),q([Y(q([V("icon"),(()=>{let N=z.state;if(N instanceof h)return P();else if(N instanceof f)return P();else if(N instanceof H)return P();else if(N instanceof M)return P();else return V("hljs-comment")})()]),q([Q(">")])),zq(q([n(z.state instanceof G),a("text"),l(!1),L("off"),c("off"),s(z.command),d(Mq(z.state)),r("terminal-prompt-field"),Qq((N)=>{return new F(N)}),Sq((N)=>{return new y(N)})]))]))]))),e(q([]),`#terminal-prompt-field {
        background-color: transparent;
        font-size: inherit;
        width: 100%;
      }

      #terminal-prompt-field:focus {
        outline: none;
      }
    `)]))}function xq(){let z=Jq(Kq,kq,Uq),J=Nq(z,"#terminal",W(6)+1);if(!(J instanceof T))throw p("let_assert",Eq,"blog/interactive/birdie_terminal",44,"main","Pattern match failed, no pattern matched the value.",{value:J,start:721,end:805,pattern_start:732,pattern_end:737});return}xq();
