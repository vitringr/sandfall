/* @refresh reload */
import { render } from "solid-js/web";
import { onMount } from "solid-js";

import { Sandfall } from "./main/sandfall";

import "./styles/reset.css";
import "./styles/style.css";

const root = document.getElementById("root");
if (!root) throw new Error("Invalid #root HTML element!");

function App() {
  let canvasRef!: HTMLCanvasElement;

  onMount(() => {
    new Sandfall(canvasRef).init();
  });

  return (
    <div>
      <canvas ref={canvasRef} />
    </div>
  );
}

render(App, root);
