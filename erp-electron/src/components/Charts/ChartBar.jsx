import React from "react";
import { Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const GraficoBarra = ({ labels, valores, titulo, nomeDataset }) => {
  const data = {
    labels,
    datasets: [
      {
        label: nomeDataset || "Dados",
        data: valores,
        backgroundColor: "rgba(75, 192, 192, 0.5)",
        borderColor: "rgba(75, 192, 192, 1)",
        borderWidth: 1,
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

  return <Bar data={data} options={options} />;
};

export default GraficoBarra;
