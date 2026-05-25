import React from "react";
import { Pie } from "react-chartjs-2";
import { Chart as ChartJS, ArcElement, Tooltip, Legend, Title } from "chart.js";

ChartJS.register(ArcElement, Tooltip, Legend, Title);

const GraficoPizza = ({ labels, valores, titulo, nomeDataset }) => {
  const data = {
    labels,
    datasets: [
      {
        label: nomeDataset || "Dados",
        data: valores,
        backgroundColor: [
          "rgb(255, 99, 132)",
          "rgb(54, 162, 235)",
          "rgb(255, 205, 86)",
          "rgb(75, 192, 192)",
          "rgb(153, 102, 255)",
          "rgb(255, 159, 64)",
        ],
        hoverOffset: 6,
      },
    ],
  };

  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: "top",
      },
      title: {
        display: !!titulo,
        text: titulo,
      },
    },
  };

  return <Pie data={data} options={options} />;
};

export default GraficoPizza;
