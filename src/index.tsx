/* @refresh reload */
import { render } from "solid-js/web";
import { onMount } from "solid-js";

import "./styles/reset.css";
import "./styles/style.css";
import { Main } from "./main";

const root = document.getElementById("root");
if (!root) throw new Error("Invalid #root HTML element!");

function App() {
  let canvasRef!: HTMLCanvasElement;

  onMount(() => {
    new Main(canvasRef).setup();
  });

  return (
    <div>
      <canvas ref={canvasRef} />
    </div>
  );
}

render(App, root);
