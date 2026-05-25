import React from "react";
import { PolarArea } from "react-chartjs-2";
import {
  Chart as ChartJS,
  RadialLinearScale,
  ArcElement,
  Tooltip,
  Legend,
  Title,
} from "chart.js";

ChartJS.register(RadialLinearScale, ArcElement, Tooltip, Legend, Title);

const GraficoPolar = ({ labels, valores, titulo, nomeDataset }) => {
  const data = {
    labels,
    datasets: [
      {
        label: nomeDataset || "Dados",
        data: valores,
        backgroundColor: [
          "rgb(255, 99, 132)",
          "rgb(75, 192, 192)",
          "rgb(255, 205, 86)",
          "rgb(201, 203, 207)",
          "rgb(54, 162, 235)",
        ],
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

  return <PolarArea data={data} options={options} />;
};

export default GraficoPolar;
