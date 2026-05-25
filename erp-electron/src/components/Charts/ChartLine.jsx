import React from "react";
import { Line } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const GraficoLinha = ({ labels, valores, titulo, nomeDataset }) => {
  const data = {
    labels,
    datasets: [
      {
        label: nomeDataset || "Dados",
        data: valores,
        fill: false,
        borderColor: "rgb(75, 192, 192)",
        backgroundColor: "rgba(75, 192, 192, 0.5)",
        tension: 0.1,
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

  return <Line data={data} options={options} />;
};

export default GraficoLinha;
